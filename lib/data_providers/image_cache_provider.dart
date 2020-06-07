import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/cache_provider.dart';
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

  Future<String> getCoverArt(String artId) async {
    final db = await database;
    final response = await db.query(
      dbName,
      columns: ['location'],
      where: 'artId = ?',
      whereArgs: [artId],
    );
    if (response.isEmpty) return null;
    return response.first['location'];
  }

  Future<String> cacheImage(String artId, List<int> downloadedBytes) async {
    // Generator random filename and write file to cache
    final name = idGenerator.v4();
    final location = p.join(await cacheLocation, name);
    final newFile = await File(location).create(recursive: true);
    await newFile.writeAsBytes(downloadedBytes);
    final size = newFile.statSync().size;

    final db = await database;
    await db.insert(dbName, {
      'artId': artId,
      'location': location,
      'size': size,
    });
    // Make sure cache still adheres to size constraints
    this.checkCacheSize();
    // Return the cached location for display
    return location;
  }
}
