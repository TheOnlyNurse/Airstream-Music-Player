import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart' as XML;

class ImageCacheProvider extends DatabaseProvider {
  @override
  String get dbName => 'imageCache';

  @override
  Future<String> get directoryPath async => (await getTemporaryDirectory()).path;

  @override
  String get tableColumns => 'url TEXT NOT NULL,'
      'location TEXT NOT NULL,'
      'size INTEGER NOT NULL';

//  Pass variables required to database provider. AlbumsDatabase is a singleton.
  ImageCacheProvider._internal();

  static final ImageCacheProvider _instance = ImageCacheProvider._internal();

  factory ImageCacheProvider() {
    return _instance;
  }

  final Uuid _idGenerator = Uuid();
  final String _cacheFolderName = 'images';

  // Dart reads files in bytes.
  int _maxCacheSize = 20 * 1024 * 1024;

  // Used to stop multiple check cache (and thus delete) method calls from firing concurrently
  Future<Null> _cacheLocker;

  Future urlQuery(String url) async {
    final db = await database;
    final response = await db.rawQuery('SELECT location FROM $dbName WHERE url = "$url"');
    if (response.isEmpty) return '';
    // Response is a list of lists despite only have one returned value. The first value will give the row. The second the column.
    return response.first.values.first.toString();
  }

  Future _checkCacheSize() async {
    // Check if cache is already being checked
    if (_cacheLocker != null) {
      await _cacheLocker;
      return _checkCacheSize();
    }

    // Lock the cache from being deleted
    var completer = new Completer<Null>();
    _cacheLocker = completer.future;

    // Get the stats of the cache directory
    final db = await database;
    var rawQuery = await db.rawQuery('SELECT size FROM $dbName');
    final cacheSize = rawQuery.fold(0, (prev, curr) => prev + curr.values.first);
    // Standardise the cache size and compare
    if (cacheSize > _maxCacheSize) {
      // Get the rowId => location of file => delete file => delete database entry
      var rawQuery =
          await db.rawQuery('SELECT location FROM $dbName ORDER BY ROWID ASC LIMIT 1');
      final fileLocation = rawQuery.first.values.first;
      final File cachedFile = File(fileLocation);
      if (await cachedFile.exists()) cachedFile.delete();
      await db.rawDelete('DELETE FROM $dbName WHERE location="$fileLocation"');
    }

    // Unlock resources
    completer.complete();
    _cacheLocker = null;
  }

  Future cacheUrl(String url, List<int> downloadedBytes) async {
    // Generator random filename and write file to cache
    final String fileName = _idGenerator.v4();
    final Directory dir = await getTemporaryDirectory();
    final String fileLocation = join(dir.path, _cacheFolderName, fileName);
    final File file = await File(fileLocation).create(recursive: true);
    await file.writeAsBytes(downloadedBytes);
    final fileSize = file.statSync().size;
    // Attach reference of cached file to database
    final db = await database;
    await db.rawInsert(
        'INSERT INTO $dbName (url, location, size) VALUES("$url", "$fileLocation", "$fileSize")');
    // Make sure cache still adheres to size constraints
    _checkCacheSize();
    // Return the cached location for display
    return fileLocation;
  }

  @override
  Future updateWithDoc(XML.XmlDocument doc) => throw UnimplementedError();

  @override
  Future updateWithDocList(List<XML.XmlDocument> docList) => throw UnimplementedError();

  @override
  Future getLibraryList() => throw UnimplementedError();
}
