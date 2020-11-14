import 'dart:async';
import 'dart:io';

import 'package:airstream/common/global_assets.dart';
import 'package:airstream/common/repository/server_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:mutex/mutex.dart';
import 'package:path/path.dart' as path;

import '../providers/image_provider.dart';
import '../providers/moor_database.dart';

class ImageRepository {
  ImageRepository({ImageFileProvider provider, ServerRepository server})
      : _provider = provider ?? _initProvider(),
        _server = getIt<ServerRepository>(server);

  /// Provider instance that servers as a database.
  final ImageFileProvider _provider;

  final ServerRepository _server;

  /// Mutex to "queue" checkSize jobs instead of having concurrent checks
  final _sizeLocker = Mutex();

  /// Timer used to "queue" cache size checks
  Timer _cacheCheckTimer;

  /// ========== QUERYING ==========

  /// Returns a low resolution image given an id.
  Future<File> preview(String artId) async {
    const type = ImageType.lowRes;
    return _query(
      id: artId,
      type: type,
      onNone: _fromServer(artId, type),
    );
  }

  /// Returns a high resolution image given an id.
  Future<File> highDefinition(String artId) async {
    const type = ImageType.highRes;
    final query = await _query(
      id: artId,
      type: type,
      onNone: _fromServer(artId, type),
    );
    return query ?? await preview(artId);
  }

  /// Returns an artist's image and fetches from discogs if prompted.
  ///
  /// Falls back to cover art image if no image is available.
  Future<File> fromArtist(Artist artist, {bool fetch = false}) async {
    const type = ImageType.artist;
    final id = artist.art ?? artist.id.toString();
    final query = await _query(
      id: id,
      type: type,
      onNone: fetch ? _fromDiscogs(artist.name, id, type) : null,
    );

    // Fallback to high-definition if possible.
    if (query != null) {
      return query;
    } else if (artist.art != null) {
      // High resolution images are only required if also fetching from discogs.
      return fetch ? highDefinition(artist.art) : preview(artist.art);
    } else {
      return null;
    }
  }

  /// ========== DB MANAGEMENT ==========

  Future<void> clear() => _provider.clear();

  Future<File> _fromServer(String id, ImageType type) async {
    final resolution = type == ImageType.lowRes ? 256 : 512;
    return (await _server.image(id, resolution)).fold(
      (error) => null,
      (bytes) {
        _queueSizeCheck();
        return _provider.addBytes(bytes, id, type);
      },
    );
  }

  Future<File> _fromDiscogs(String name, String id, ImageType type) async {
    return (await _server.discogsImage(name)).fold(
      (error) {
        _provider.setNull(id, type);
        return null;
      },
      (bytes) {
        _queueSizeCheck();
        return _provider.addBytes(bytes, id, type);
      },
    );
  }

  /// Queues size check calls
  ///
  /// Size checks once initiated ensures that the cache stays within user set
  /// limits. Therefore, only one check should be submitted, this "queues" up
  /// the calls with a timer.
  void _queueSizeCheck() {
    if (_cacheCheckTimer != null) {
      _cacheCheckTimer.cancel();
    }
    _cacheCheckTimer = Timer(const Duration(seconds: 5), _initiateSizeCheck);
  }

  Future<void> _initiateSizeCheck() async {
    if (!_sizeLocker.isLocked) {
      await _sizeLocker.protect(() => _provider.checkSize());
    }
  }

  /// ========== COMMON FUNCTIONS ==========

  Future<File> _query({
    @required String id,
    @required ImageType type,
    Future<File> onNone,
  }) async {
    assert(id != null);
    assert(type != null);

    final fileState = _provider.getState(id, type);

    switch (fileState) {
      case ImageFileState.exists:
        return _provider.getFile(id, type);
        break;
      case ImageFileState.nullFile:
        return null;
        break;
      case ImageFileState.none:
        return onNone;
        break;
      default:
        throw UnimplementedError('Failed to interpret: $type');
    }
  }

  Future<List<File>> collage(List<int> songIds) async {
    throw UnimplementedError();
    // final images = <File>[];
    // for (var id in songIds) {
    //   final response = await Repository().song.byId(id);
    //   final art =
    //       response.hasData ? await highDefinition(response.data.first.art) : null;
    //   if (response != null) images.add(art);
    // }
    // if (images.isEmpty) return null;
    // return images;
  }
}

ImageFileProvider _initProvider() {
  final root = GetIt.I.get<String>(instanceName: 'cachePath');
  final folder = path.join(root, 'images/');
  return ImageFileProvider(hive: Hive.box<int>('images'), cacheFolder: folder);
}
