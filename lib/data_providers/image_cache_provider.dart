import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/cache_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:path/path.dart' as p;

class ImageCacheProvider extends CacheProvider {
  @override
  String get dbName => 'imageCache';

  @override
  String get tableColumns => 'artId TEXT NOT NULL,'
      'location TEXT NOT NULL,'
      'size INTEGER NOT NULL';

  @override
  int get maxCacheSize => 20 * 1024 * 1024;

  ImageCacheProvider._internal();

  static final ImageCacheProvider _instance = ImageCacheProvider._internal();

  factory ImageCacheProvider() {
    return _instance;
  }

  final virtualCache = <String, String>{};

  /// Check cache for image and download if absent.
  ///
  /// The max image resolution has been chosen to be 512 pixels because of cache size
  /// constraints and little appreciable benefit of higher resolutions.
  Future<String> getCoverArt(String artId, bool isHiDef) async {
    String modifiedId = artId;
    if (isHiDef) modifiedId = artId + 'hiDef';

    if (virtualCache.containsKey(modifiedId)) return virtualCache[modifiedId];

    final db = await database;
    final response = await db.query(
      dbName,
      columns: ['location'],
      where: 'artId = ?',
      whereArgs: [modifiedId],
    );
    if (response.isEmpty) return await _downloadImage(artId, isHiDef);
    return response.first['location'];
  }

  Future<String> _downloadImage(String artId, bool isHiDef) async {
    String url =
        isHiDef ? 'getCoverArt?id=$artId&size=512&' : 'getCoverArt?id=$artId&size=256&';
    final response = await ServerProvider().downloadFile(url);
    if (response == null) return null;
    return await this._cacheImage(artId, isHiDef, response.bodyBytes);
  }

  Future<String> _cacheImage(
      String artId, bool isHiDef, List<int> downloadedBytes) async {
    String modifiedId = artId;
    if (isHiDef) modifiedId = artId + 'hiDef';
    // Generator random filename and write file to cache
    final name = idGenerator.v4();
    final filePath = p.join(await cacheLocation, name);
    final newFile = await File(filePath).create(recursive: true);
    await newFile.writeAsBytes(downloadedBytes);
    final size = newFile.statSync().size;

    final db = await database;
    await db.insert(dbName, {
      'artId': modifiedId,
      'location': filePath,
      'size': size,
    });
    // Make sure cache still adheres to size constraints
    this.checkCacheSize();

    virtualCache[modifiedId] = filePath;

    // Return the cached location for display
    return filePath;
  }
}
