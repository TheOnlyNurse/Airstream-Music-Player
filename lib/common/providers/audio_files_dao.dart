import 'package:moor/moor.dart';

/// Internal Links
import 'moor_database.dart';

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
}
