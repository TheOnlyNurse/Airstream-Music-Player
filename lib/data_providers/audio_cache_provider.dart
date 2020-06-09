import 'dart:io';
import 'package:airstream/data_providers/cache_provider.dart';
import 'package:path/path.dart' as p;

class AudioCacheProvider extends CacheProvider {
  @override
  String get dbName => 'audioCache';

  @override
  int get maxCacheSize => 100 * 1024 * 1024;

  @override
  String get tableColumns => 'location TEXT NOT NULL,'
      'songId TEXT,'
      'artist TEXT,'
      'albumId TEXT,'
      'size INTEGER NOT NULL';

  AudioCacheProvider._internal();

  static final AudioCacheProvider _instance = AudioCacheProvider._internal();

  factory AudioCacheProvider() {
    return _instance;
  }

  Future<String> getSongLocation(String songId) async {
    final db = await database;
    final response = await db.query(
      dbName,
      columns: ['location'],
      where: 'songId = ?',
      whereArgs: [songId],
    );
    if (response.length > 0) {
      return response.first['location'];
    }
    return null;
  }

  /// Cache audio files that have been downloaded
  ///
  /// Songs and albums can be reliably tracked by their id. Artists cannot. Therefore,
  /// artist names are used instead.
  Future<String> cacheFile(File audioFile,
      {String songId, String artistName, String albumId}) async {
    // Generator random filename and write file to cache
    final String fileName = idGenerator.v4();
    final String filePath = p.join(await cacheLocation, fileName);
    final File file = await File(filePath).create(recursive: true);
    await file.writeAsBytes(audioFile.readAsBytesSync());
    final fileSize = file.statSync().size;
    // Attach reference of cached file to database
    final db = await database;
    await db.insert(dbName, {
      'location': filePath,
      'songId': songId,
      'artist': artistName,
      'albumId': albumId,
      'size': fileSize,
    });
    // Make sure cache still adheres to size constraints
    this.checkCacheSize();
    // Return the cached location for display
    return filePath;
  }

  Future deleteSongFile(String songId) async {
    final db = await database;
    final details = await db.query(dbName, where: 'songId = ?', whereArgs: [songId]);
    await db.delete(dbName, where: 'songId = ?', whereArgs: [songId]);
    final cacheFile = File(details.first['location']);
    if (cacheFile.existsSync()) cacheFile.deleteSync();
  }
}
