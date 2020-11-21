import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart';

import '../../global_assets.dart';
import '../providers/image_provider.dart';
import '../providers/moor_database.dart';
import 'server_repository.dart';

class ImageRepository {
  ImageRepository({ImageFileProvider provider, ServerRepository server})
      : _provider = provider ?? _initProvider(),
        _server = getIt<ServerRepository>(server) {
    _cacheCheck.stream
        .debounce((_) => TimerStream(true, const Duration(seconds: 3)))
        .listen((_) {
      // print('Checking cache size');
      _provider.checkSize();
    });
  }

  /// Provider instance that servers as a database.
  final ImageFileProvider _provider;

  /// Provider used to fetch images.
  final ServerRepository _server;

  final _cacheCheck = StreamController<bool>();

  /// ========== QUERYING ==========

  /// Returns a low resolution image given an id.
  Future<Option<File>> preview(String artId) async {
    const type = ImageType.lowRes;
    return _provider
        .state(artId, type)
        .fold(() => none(), _resolveState(artId, type, _fromSubsonic));
  }

  /// Returns a high resolution image given an id.
  Future<Option<File>> highDefinition(String artId) async {
    const type = ImageType.highRes;
    return _provider.state(artId, type).fold(
      () => none(),
      // Fallback to low resolution if unable to get high definition image.
      (state) async {
        final file = await _resolveState(artId, type, _fromSubsonic)(state);
        return file.isNone() ? await preview(artId) : file;
      },
    );
  }

  /// Returns an artist's image and fetches from discogs if prompted.
  ///
  /// Falls back to cover art image if no image is available.
  Future<Option<File>> fromArtist(Artist artist, {bool fetch = false}) async {
    const type = ImageType.artist;
    final id = artist.art ?? artist.id.toString();

    // Resolve the state from the database.
    final query = _provider.state(id, type).fold<Future<Option<File>>>(
          () async => none(),
          _resolveState(
            id,
            type,
            fetch ? _fromDiscogs(artist.name) : (_, __) async => none(),
          ),
        );

    // If the state is still none after resolving, fallback to album artwork.
    return (await query).fold(() async {
      // Only fallback if artwork id is available.
      return artist.art != null
          ? fetch
              ? await highDefinition(artist.art)
              : await preview(artist.art)
          : none();
    }, (file) => some(file));
  }

  /// Deletes all cache files and clears their references in the database.
  Future<void> clear() => _provider.clear();

  /// Resolves a file state given from the provider.
  ///
  /// Fetches from Subsonic if the file is missing.
  Future<Option<File>> Function(bool) _resolveState(
    String artId,
    ImageType type,
    Future<Option<File>> Function(String id, ImageType type) onMissing,
  ) {
    return (bool fileExists) async {
      return fileExists
          ? some(_provider.resolveFile(artId, type))
          : await onMissing(artId, type);
    };
  }

  Future<Option<File>> _fromSubsonic(String artId, ImageType type) async {
    final resolution = type == ImageType.lowRes ? 256 : 512;
    return (await _server.image(artId, resolution))
        .toOption()
        .fold(() => none(), (bytes) async {
      _cacheCheck.add(true);
      return some(await _provider.addBytes(bytes, artId, type));
    });
  }

  Future<Option<File>> Function(String, ImageType) _fromDiscogs(String name) {
    return (String id, ImageType type) async {
      return (await _server.discogsImage(name)).fold(
        // Add a null file to prevent more fetch attempts of the same artist.
        (error) {
          _provider.addNull(id, type);
          return none();
        },
        (bytes) async {
          _cacheCheck.add(true);
          return some(await _provider.addBytes(bytes, id, type));
        },
      );
    };
  }

  Future<List<File>> collage(List<int> songIds) async =>
      throw UnimplementedError();
}

ImageFileProvider _initProvider() {
  final root = GetIt.I.get<String>(instanceName: 'cachePath');
  final folder = path.join(root, 'images/');
  return ImageFileProvider(hive: Hive.box<int>('images'), cacheFolder: folder);
}
