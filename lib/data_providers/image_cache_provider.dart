import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/cache_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:path/path.dart' as p;

class ImageCacheProvider extends CacheProvider {
  /// Global functions
  ///
  /// Check cache for image and download if absent
  /// The max image resolution has been chosen to be 512 pixels because of cache size
  /// constraints and little appreciable benefit of higher resolutions.
  Future<ProviderResponse> query(String artId, bool isHiDef) async {
    String modifiedId = artId;
    if (isHiDef) modifiedId = artId + 'HiDef';

    final db = await database;
    final response = await db.query(
      dbName,
      columns: ['location'],
      where: 'artId = ?',
      whereArgs: [modifiedId],
    );

    if (response.isEmpty) {
      return await _downloadImage(artId, isHiDef);
    } else {
      final image = File(response.first['location']);
      return ProviderResponse(status: DataStatus.ok, data: image);
    }
  }

  /// Private functions
  Future<ProviderResponse> _downloadImage(String artId, bool isHiDef) async {
    String request =
        isHiDef ? 'getCoverArt?id=$artId&size=512&' : 'getCoverArt?id=$artId&size=256&';

    final response = await ServerProvider().fetchRequest(request, FetchType.bytes);
    if (response.status == DataStatus.error) return response;
    assert(response.data is List<int>);

    final image = File(await _cacheImage(artId, isHiDef, response.data));
    return ProviderResponse(status: DataStatus.ok, data: image);
  }

  Future<String> _cacheImage(String artId,
      bool isHiDef,
      List<int> downloadedBytes,) async {
    String modifiedId = artId;
    if (isHiDef) modifiedId = artId + 'hiDef';
    // Generator random filename and write file to cache
    final filePath = p.join(await cacheLocation, modifiedId);
    final newFile = await File(filePath).create(recursive: true);
    await newFile.writeAsBytes(downloadedBytes);
    final size = newFile
        .statSync()
        .size;

    final db = await database;
    await db.insert(dbName, {'artId': modifiedId, 'location': filePath, 'size': size});

    // Make sure cache still adheres to size constraints
    this.checkCacheSize();

    // Return the cached location for display
    return filePath;
  }

  /// Cache Provider overrides
  @override
  String get dbName => 'imageCache';

  @override
  String get tableColumns => 'artId TEXT NOT NULL,'
      'location TEXT NOT NULL,'
      'size INTEGER NOT NULL';

  @override
  Future<int> get maxCacheSize async =>
      (await SettingsProvider().imageCacheSize) * 1024 * 1024;

  /// Singleton boilerplate code
  ImageCacheProvider._internal();

  static final ImageCacheProvider _instance = ImageCacheProvider._internal();

  factory ImageCacheProvider() {
    return _instance;
  }
}
