import 'dart:collection';
import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/data_providers/moor_cache.dart';
import 'package:airstream/models/response/audio_cache_response.dart';
import 'package:moor/moor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'moor_database.dart';

part 'audio_files_dao.g.dart';

class AudioFiles extends Table {
  TextColumn get path => text()();

  IntColumn get songId => integer()();

  IntColumn get albumId => integer()();

  IntColumn get size => integer()();

  @override
  Set<Column> get primaryKey => {songId};
}

@UseDao(tables: [AudioFiles])
class AudioFilesDao extends DatabaseAccessor<MoorCache>
    with _$AudioFilesDaoMixin {
  /// So that the main database can create an instance of this dao
  AudioFilesDao(MoorCache db) : super(db);

  /// Used to generate unique names for cache files
  final Uuid _idGenerator = Uuid();

  /// Mutex to "queue" cache size checks to stop incorrect multiple deletes
  final _sizeLocker = Mutex();

  /// User set maximum cache size
  Future<int> get _maxSize async {
    final userSetSize = SettingsProvider().query(SettingType.musicCache);
    return userSetSize * 1024 * 1024;
  }

  /// Location of the cache folder
  Future<String> get _cacheFolder async {
    return p.join((await getTemporaryDirectory()).path, 'audio/');
  }

  /// Returns a file path given a song id
  Future<AudioCacheResponse> pathOf(int songId) async {
    final query = select(audioFiles);
    query.where((tbl) => tbl.songId.equals(songId));
    final result = await query.getSingle();
    if (result == null) {
      return AudioCacheResponse(error: 'Failed to find song in cache');
    } else {
      return AudioCacheResponse(hasData: true, path: result.path);
    }
  }

  /// Returns a list of cached album or song ids
  Future<AudioCacheResponse> cachedIds(String request) async {
    assert(request == 'songs' || request == 'albums');
    final query = selectOnly(audioFiles);
    GeneratedIntColumn expression;
    if (request == 'songs') {
      expression = audioFiles.songId;
    }
    if (request == 'albums') {
      expression = audioFiles.albumId;
    }
    query.addColumns([expression]);
    final result = (await query.get()).map((row) => row.read(expression));
    final condensed = LinkedHashSet<int>.from(result.toList());
    if (condensed.isEmpty) {
      return AudioCacheResponse(error: 'No cached songs found.');
    } else {
      return AudioCacheResponse(hasData: true, idList: condensed.toList());
    }
  }

  /// Cache file and insert into database, returning the generated new path
  Future<AudioCacheResponse> cache(File audioFile, Song song) async {
    // Generator random filename and write file to cache
    final name = _idGenerator.v4();
    final path = p.join(await _cacheFolder, name);
    final cacheFile = await File(path).create(recursive: true);
    cacheFile.writeAsBytesSync(audioFile.readAsBytesSync());
    await _insertCompanion(_getCompanion(cacheFile, song));
    return AudioCacheResponse(hasData: true, path: path);
  }

  /// Makes sure current cache size is within max cache size, delete oldest file
  /// if it isn't
  void checkSize() async {
    await _sizeLocker.protect(() async {
      final sum = audioFiles.size.sum();
      final query = selectOnly(audioFiles);
      query.addColumns([sum]);
      final cacheSize = await query.map((row) => row.read(sum)).getSingle();
      if (cacheSize > await _maxSize) {
        await _deleteOldestFile();
        checkSize();
      }
    });
  }

  /// Deletes all entries
  Future<int> deleteAll() async {
    return delete(audioFiles).go();
  }

  /// Delete cached file and row by song id
  Future<Null> deleteSong(int songId) async {
    final query = select(audioFiles);
    query.where((tbl) => tbl.songId.equals(songId));
    final file = File((await query.getSingle()).path);
    file.deleteSync();
    return _deleteRow(songId);
  }

  /// Deletes row by song id (the primary key)
  Future<Null> _deleteRow(int songId) {
    final deleteRow = delete(audioFiles);
    deleteRow.where((tbl) => tbl.songId.equals(songId));
    return deleteRow.go();
  }

  /// Delete the oldest file (which would be the first entry) in the database
  Future<Null> _deleteOldestFile() async {
    final query = await select(audioFiles).getSingle();
    final file = File(query.path);
    file.deleteSync();
    return _deleteRow(query.songId);
  }

  /// Inserts companion into the cache
  Future<int> _insertCompanion(AudioFilesCompanion entry) {
    return into(audioFiles).insert(entry);
  }

  /// Returns a properly distributed companion
  AudioFilesCompanion _getCompanion(File file, Song song) {
    return AudioFilesCompanion(
      path: Value(file.path),
      songId: Value(song.id),
      albumId: Value(song.albumId),
      size: Value(file.statSync().size),
    );
  }
}
