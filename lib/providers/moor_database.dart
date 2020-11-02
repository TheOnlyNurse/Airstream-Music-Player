/// External Packages
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

/// Internal Links
import 'albums_dao.dart';
import 'artists_dao.dart';
import 'songs_dao.dart';

part 'moor_database.g.dart';

@UseMoor(
  tables: [Albums, Artists, Songs],
  daos: [AlbumsDao, ArtistsDao, SongsDao],
)
class MoorDatabase extends _$MoorDatabase {
  /// Load into memory if not opened in isolate
  MoorDatabase() : super(VmDatabase.memory());

  /// Constructor for isolate communication
  MoorDatabase.connect(DatabaseConnection connection)
      : super.connect(connection);

  @override
  int get schemaVersion => 1;
}
