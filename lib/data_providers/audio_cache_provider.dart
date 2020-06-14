import 'dart:io';
import 'package:airstream/data_providers/cache_provider.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:path/path.dart' as p;

class AudioCacheProvider extends CacheProvider {
  @override
  String get dbName => 'audioCache';

  @override
  Future<int> get maxCacheSize async =>
      (await SettingsProvider().musicCacheSize) * 1024 * 1024;

  @override
  String get tableColumns => 'location TEXT NOT NULL,'
      'songId INTEGER,'
      'albumId INTEGER,'
      'size INTEGER NOT NULL';

  AudioCacheProvider._internal();

  static final AudioCacheProvider _instance = AudioCacheProvider._internal();

  factory AudioCacheProvider() {
    return _instance;
  }

  Future<ProviderResponse> getCachedList({
    bool songs = false,
    bool albums = false,
  }) async {
    assert(songs != albums);

    final db = await database;
    final queryArgs = <String, dynamic>{};

    if (songs) {
      queryArgs['columns'] = ['songId'];
    }
    if (albums) {
      queryArgs['columns'] = ['albumId'];
    }

    final response = await db.query(dbName, columns: queryArgs['columns']);

    if (response.isEmpty) {
      return ProviderResponse(
				status: DataStatus.error,
        source: ProviderSource.audioCache,
        message: 'no cached songs',
      );
    }
    if (songs) {
      final songIds = response.map((e) => e['songId'] as int).toList();
      return ProviderResponse(status: DataStatus.ok, data: songIds);
    }
    if (albums) {
      final albumList = response.map((e) => e['albumId'] as int).toList();
      return ProviderResponse(status: DataStatus.ok, data: albumList);
    }

    throw UnimplementedError();
  }

  Future<String> getSongLocation(int songId) async {
    final db = await database;
    final response = await db.query(dbName,
        columns: ['location'], where: 'songId = ?', whereArgs: [songId]);
    if (response.isNotEmpty) {
      return response.first['location'];
    }
    return null;
  }

  /// Cache audio files that have been downloaded
  ///
  /// Songs and albums can be reliably tracked by their id. Artists cannot. Therefore,
  /// artist names are used instead.
  Future<String> cacheFile(File audioFile,
      {int songId, String artistName, int albumId}) async {
    // Generator random filename and write file to cache
    final String name = idGenerator.v4();
    final String path = p.join(await cacheLocation, name);
    final File cacheFile = await File(path).create(recursive: true);
    await cacheFile.writeAsBytes(audioFile.readAsBytesSync());
    final fileSize = cacheFile.statSync().size;
    // Attach reference of cached file to database
    final db = await database;
    await db.insert(dbName, {
      'location': path,
      'songId': songId,
      'albumId': albumId,
      'size': fileSize,
    });
    // Make sure cache still adheres to size constraints
    this.checkCacheSize();
    // Return the cached location for display
    return path;
  }

  Future deleteSongFile(int songId) async {
    final db = await database;
    final details = await db.query(dbName, where: 'songId = ?', whereArgs: [songId]);
    await db.delete(dbName, where: 'songId = ?', whereArgs: [songId]);
    final cacheFile = File(details.first['location']);
    if (cacheFile.existsSync()) cacheFile.deleteSync();
  }
}
