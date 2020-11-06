import 'dart:collection';
import 'dart:io';

import 'package:moor/moor.dart';
import 'package:mutex/mutex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Internal Links
import 'moor_database.dart';
import '../repository/communication.dart';
import '../models/response/audio_cache_response.dart';
import 'settings_provider.dart';

part 'audio_files_dao.g.dart';

class AudioFiles extends Table {
  IntColumn get songId => integer().customConstraint('REFERENCES songs(id)')();

  TextColumn get path => text()();

  IntColumn get size => integer()();

  DateTimeColumn get created => dateTime()();

  @override
  Set<Column> get primaryKey => {songId};
}

@UseDao(tables: [AudioFiles])
class AudioFilesDao extends DatabaseAccessor<MoorDatabase>
    with _$AudioFilesDaoMixin {
  /// So that the main database can create an instance of this dao
  AudioFilesDao(MoorDatabase db) : super(db);

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

  /// ========== QUERYING ==========

  /// Returns a file path (if it exists) given a song id.
  Future<String> filePath(int songId) {
    final query = select(audioFiles)..where((tbl) => tbl.songId.equals(songId));
    return query.map((row) => row.path).getSingle();
  }

  /// Returns the AudioFile entry associated with a song id.
  Future<AudioFile> query(int songId) {
    final query = select(audioFiles)..where((tbl) => tbl.songId.equals(songId));
    return query.getSingle();
  }

  Future<int> cacheSize() {
    final sum = audioFiles.size.sum();
    final query = selectOnly(audioFiles)..addColumns([sum]);
    return query.map((row) => row.read(sum)).getSingle();
  }

  Future<AudioFile> oldestFile(int offset) {
    return (select(audioFiles)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.created)])
          ..limit(1, offset: offset))
        .getSingle();
  }

  /// ========== DB MANAGEMENT ==========

  /// Delete a table entry given a song id.
  ///
  /// Do note that this does not remove the underlying file, only the database entry.
  Future<void> deleteEntry(int songId) {
    return (delete(audioFiles)..where((tbl) => tbl.songId.equals(songId))).go();
  }

  /// Insert a companion into the database.
  Future<void> insertCompanion(AudioFilesCompanion entry) {
    return into(audioFiles).insert(entry);
  }

  /// Removes all entries in database.
  ///
  /// This does not alter/delete the referenced files.
  Future<void> clear() => delete(audioFiles).go();

  /// Returns a list of cached album or song ids
  Future<AudioCacheResponse> cachedIds(String request) async {
    assert(request == 'songs' || request == 'albums');
    final query = selectOnly(audioFiles);
    GeneratedIntColumn expression;
    if (request == 'songs') {
      expression = audioFiles.songId;
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
    final name = '${song.id}.${song.title.hashCode}';
    final path = p.join(await _cacheFolder, name);
    final cacheFile = await File(path).create(recursive: true);
    cacheFile.writeAsBytesSync(audioFile.readAsBytesSync());
    await insertCompanion(await _getCompanion(cacheFile, song));
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
  Future<void> deleteSong(int songId) async {
    final query = select(audioFiles);
    query.where((tbl) => tbl.songId.equals(songId));
    final file = File((await query.getSingle()).path);
    file.deleteSync();
    return _deleteRow(songId);
  }

  /// Deletes row by song id (the primary key)
  Future<void> _deleteRow(int songId) {
    final deleteRow = delete(audioFiles);
    deleteRow.where((tbl) => tbl.songId.equals(songId));
    return deleteRow.go();
  }

  /// Delete the oldest file (which would be the first entry) in the database
  Future<void> _deleteOldestFile() async {
    final query = await select(audioFiles).getSingle();
    final file = File(query.path);
    file.deleteSync();
    return _deleteRow(query.songId);
  }

  /// Returns a properly distributed companion
  Future<AudioFilesCompanion> _getCompanion(File file, Song song) async {
    return AudioFilesCompanion.insert(
      path: file.path,
      songId: Value(song.id),
      size: (await file.stat()).size,
      created: DateTime.now(),
    );
  }
}
