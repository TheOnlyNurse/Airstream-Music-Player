import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mutex/mutex.dart';

/// Internal
import '../providers/image_provider.dart';
import '../providers/moor_database.dart';
import '../providers/server_provider.dart';

class ImageRepository {
  ImageRepository(this._provider);

  final ImageFileProvider _provider;

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
    return query != null ? query : preview(artId);
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
    final url = 'getCoverArt?id=$id&size=$resolution';
    final response = await ServerProvider().fetchImage(url);
    if (response.hasData) {
      _queueSizeCheck();
      return _provider.addBytes(response.bytes, id, type);
    } else {
      return null;
    }
  }

  Future<File> _fromDiscogs(String name, String id, ImageType type) async {
    final response = await ServerProvider().fetchArtistImage(name);
    if (response.hasData) {
      _queueSizeCheck();
      return _provider.addBytes(response.bytes, id, type);
    } else {
      _provider.setNull(id, type);
      return null;
    }
  }

  /// Queues size check calls
  ///
  /// Size checks once initiated ensures that the cache stays within user set
  /// limits. Therefore, only one check should be submitted, this "queues" up
  /// the calls with a timer.
  void _queueSizeCheck() async {
    if (_cacheCheckTimer != null) {
      _cacheCheckTimer.cancel();
    }
    _cacheCheckTimer = Timer(Duration(seconds: 5), _initiateSizeCheck);
  }

  void _initiateSizeCheck() async {
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
