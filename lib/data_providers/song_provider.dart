import 'dart:io';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/song_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart' as XML;
import 'package:path/path.dart' as p;

class SongProvider extends DatabaseProvider {
  @override
  String get dbName => 'songs';

  @override
  Future<String> get directoryPath => getDatabasesPath();

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'albumName TEXT,'
      'artistName TEXT,'
      'duration INT,'
      'coverArt TEXT,'
      'albumId INTEGER,'
      'artistID INTEGER,'
      'starred INTEGER,'
      'location TEXT';

  SongProvider._internal();

  static final SongProvider _instance = SongProvider._internal();

  factory SongProvider() => _instance;

  final Uuid _idGenerator = Uuid();
  final String _songCacheFolder = 'songCache';

  Future<List<Song>> getLibraryList() async {
    final db = await database;
    final response =
        await db.rawQuery('SELECT * FROM $dbName WHERE starred = 1 ORDER BY name ASC');
    List<Song> list = response.map((a) => Song.fromMap(a)).toList();
    return list;
  }

  Future getSongLocation(Song song) async {
    final db = await database;
    final response = await db.query(
      dbName,
      columns: ['location'],
      where: 'id = ?',
      whereArgs: [song.id],
    );
    return response.first['location'];
  }

  Future<String> cacheSong(Song song, String tempFilePath) async {
    final fileName = _idGenerator.v4();
    final dir = await getTemporaryDirectory();
    final cacheFile =
        await File(p.join(dir.path, _songCacheFolder, fileName)).create(recursive: true);
    cacheFile.writeAsBytesSync(File(tempFilePath).readAsBytesSync());
    final db = await database;
    await db.rawUpdate(
        'UPDATE $dbName SET location = "${cacheFile.path}" WHERE id = "${song.id}"');
    return cacheFile.path;
  }

  Future<List<Song>> getSongsFromAlbumId(int id) async {
    final db = await database;
    final response = await db
        .rawQuery('SELECT * FROM $dbName WHERE albumId = "$id" ORDER BY name ASC');
    final List<Song> list = response.map((a) => Song.fromMap(a)).toList();
    return list;
  }

  /// Update songs from an XML document
  ///
  /// Starred Songs (the library listing) can be updated multiple times. Thus if the XML
  /// document is one from a Starred Songs list, the already cached Starred Songs need
  /// to be update (easiest way being deleting and inserting).
  @override
  Future updateWithDoc(XML.XmlDocument doc, {isStarred = true}) async {
    if (doc == null) return null;
    // Extract data
    final elements = doc.findAllElements('song');
    final List<Song> songList = elements.map((a) => Song.fromXML(a)).toList();

    final db = await database;
    // Starred songs are all deleted then the new list inserted
    if (isStarred) {
      await db.delete(dbName, where: 'starred = ?', whereArgs: [1]);
      songList.forEach((a) {
        // If a starred item was first encountered somewhere other than in the starred library
        // replace that with this entry (the difference being one this one is starred).
        db.insert(dbName, a.toMapAsStarred(isStarred: isStarred),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
    // All other songs are inserted when encountered in their albums. If the song exists,
    // usually because it is in a playlist or starred then it is ignored.
    songList.forEach((a) async {
      db.insert(dbName, a.toMapAsStarred(), conflictAlgorithm: ConflictAlgorithm.ignore);
    });
    return songList;
  }

  @override
  Future updateWithDocList(List<XML.XmlDocument> docList) => throw UnimplementedError();
}
