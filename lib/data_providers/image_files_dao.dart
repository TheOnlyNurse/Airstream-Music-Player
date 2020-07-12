import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/data_providers/moor_cache.dart';
import 'package:airstream/models/response/server_response.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'image_files_dao.g.dart';

class ImageFiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get artId => text()();

  TextColumn get type => text()();

  TextColumn get path => text().nullable()();

  IntColumn get size => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [ImageFiles])
class ImageFilesDao extends DatabaseAccessor<MoorCache>
    with _$ImageFilesDaoMixin {
  /// So that the main database can create an instance of this dao
  ImageFilesDao(MoorCache db) : super(db);

  /// Mutex to "queue" checkSize jobs instead of having concurrent checks
  final _sizeLocker = Mutex();

  /// Returns the max size of the cache, as set by the user
  Future<int> get _maxSize async {
    final int userSetSize = SettingsProvider().query(SettingType.imageCache);
    return userSetSize * 1024 * 1024;
  }

  /// Returns the location of the cache
  Future<String> get _cacheFolder async {
    return p.join((await getTemporaryDirectory()).path, 'image/');
  }

  /// Returns an image type of a given art id
  Future<File> byType(ImageType type, {String artId, String name}) async {
    final art = await _getImage(artId, type);
    if (art == null) {
      return _download(type, artId: artId, name: name);
    } else {
      // Artist type might return null paths, make sure there is a file to return here
      return art.path != null ? File(art.path) : null;
    }
  }

  /// Checks to make sure cache still adheres to the user set max size
  void checkSize() async {
    await _sizeLocker.protect(() async {
      final sum = imageFiles.size.sum();
      final query = selectOnly(imageFiles);
      query.addColumns([sum]);
      final cacheSize = await query.map((row) => row.read(sum)).getSingle();
      if (cacheSize > await _maxSize) {
        await _deleteOldestFile();
        checkSize();
      }
      return;
    });
  }

  /// Returns once all files have been deleted
  Future<Null> deleteAll() async {
    final query = await select(imageFiles).get();
    query.map((c) {
      final file = File(c.path);
      file.deleteSync();
    });
    await delete(imageFiles).go();
    return;
  }

  /// Deletes the first row and thus the oldest cached file
  Future<Null> _deleteOldestFile() async {
    final query = await select(imageFiles).getSingle();
    final file = File(query.path);
    file.deleteSync();
    final deleteRow = delete(imageFiles);
    deleteRow.where((tbl) => tbl.id.equals(query.id));
    return deleteRow.go();
  }

  /// Downloads an image of either "high" or "low" definition, from the server
  Future<File> _download(ImageType type, {String artId, String name}) async {
    final response = await _serverRequest(type, artId: artId, name: name);
    if (response.hasNoData) {
      // Insert a null path to ensure that unnecessary multiple attempts are made
      if (type == ImageType.artist) _addImage(artId, type);
      return null;
    }
    final file = await _bytesToFile('$artId-$type', response.bytes);
    _addImage(artId, type, file: file);
    checkSize();
    return file;
  }

  /// Returns a specific server request given an image type
  Future<ServerResponse> _serverRequest(
    ImageType type, {
    String artId,
    String name,
  }) {
    final provider = ServerProvider();
    switch (type) {
      case ImageType.original:
        return provider.fetchImage('getCoverArt?id=$artId&size=512');
        break;
      case ImageType.thumbnail:
        return provider.fetchImage('getCoverArt?id=$artId&size=256');
        break;
      case ImageType.artist:
        return provider.fetchArtistImage(name);
      default:
        throw UnimplementedError(type.toString());
    }
  }

  /// Converts bytes into a file
  Future<File> _bytesToFile(String filename, Uint8List bytes) async {
    final path = p.join(await _cacheFolder, filename);
    final file = await File(path).create(recursive: true);
    return file.writeAsBytes(bytes);
  }

  /// Returns an image file from the cache
  Future<ImageFile> _getImage(String artId, ImageType type) async {
    final query = select(imageFiles);
    query.where((tbl) {
      return tbl.artId.equals(artId) & tbl.type.equals(type.toString());
    });
    return query.getSingle();
  }

  /// Adds companion to database
  Future<int> _addImage(String artId, ImageType type, {File file}) async {
    return into(imageFiles).insert(
      ImageFilesCompanion.insert(
        artId: artId,
        type: type.toString(),
        path: file != null ? Value(file.path) : Value(null),
        size: file != null ? file
            .statSync()
            .size : 0,
      ),
    );
  }
}

enum ImageType { original, thumbnail, artist }
