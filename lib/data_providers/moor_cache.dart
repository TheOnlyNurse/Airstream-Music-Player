import 'package:airstream/data_providers/audio_files_dao.dart';
import 'package:airstream/data_providers/image_files_dao.dart';
import 'package:moor_ffi/moor_ffi.dart';
import 'package:moor/moor.dart';

part 'moor_cache.g.dart';

@UseMoor(
  tables: [ImageFiles, AudioFiles],
  daos: [ImageFilesDao, AudioFilesDao],
)
class MoorCache extends _$MoorCache {
  /// Load into memory if not opened in isolate
  MoorCache() : super(VmDatabase.memory());

  /// Constructor for isolate communication
  MoorCache.connect(DatabaseConnection connection) : super.connect(connection);

  @override
  int get schemaVersion => 1;
}
