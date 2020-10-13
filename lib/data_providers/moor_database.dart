import 'package:airstream/data_providers/albums_dao.dart';
import 'package:airstream/data_providers/artists_dao.dart';
import 'package:airstream/data_providers/songs_dao.dart';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

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
