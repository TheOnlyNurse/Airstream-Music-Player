import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

import 'albums_dao.dart';
import 'artists_dao.dart';
import 'audio_files_dao.dart';
import 'songs_dao.dart';

part 'moor_database.g.dart';

@UseMoor(
  tables: [Albums, Artists, Songs, AudioFiles],
  daos: [AlbumsDao, ArtistsDao, SongsDao, AudioFilesDao],
)
class MoorDatabase extends _$MoorDatabase {
  /// Load into memory if not opened in isolate
  MoorDatabase() : super(VmDatabase.memory());

  /// Constructor for isolate communication
  MoorDatabase.connect(DatabaseConnection connection)
      : super.connect(connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    // Enable foreign key support to link audio files to song objects.
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    }
  );
}
