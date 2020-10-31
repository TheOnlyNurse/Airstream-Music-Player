/// External Packages
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';

/// Internal Links
import 'audio_files_dao.dart';

part 'moor_cache.g.dart';

@UseMoor(
  tables: [AudioFiles],
  daos: [AudioFilesDao],
)
class MoorCache extends _$MoorCache {
  /// Load into memory if not opened in isolate
  MoorCache() : super(VmDatabase.memory());

  /// Constructor for isolate communication
  MoorCache.connect(DatabaseConnection connection) : super.connect(connection);

  @override
  int get schemaVersion => 1;
}
