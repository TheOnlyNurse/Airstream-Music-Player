import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as XML;

class AlbumProvider extends DatabaseProvider {
  @override
  String get dbName => 'albums';

  @override
  Future<String> get directoryPath => getDatabasesPath();

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'artistName TEXT,'
      'artistId INTEGER,'
      'songCount INTEGER,'
      'coverArt TEXT';

  AlbumProvider._internal();

  static final AlbumProvider _instance = AlbumProvider._internal();

  factory AlbumProvider() {
    return _instance;
  }

//  Returns an alphabetical list of albums
  Future getLibraryList() async {
    final db = await database;
    final response = await db.rawQuery('SELECT * FROM $dbName ORDER BY name ASC');
    List<Album> list = response.map((a) => Album.fromMap(a)).toList();
    return list;
  }

  @override
  Future updateWithDocList(List<XML.XmlDocument> docList) async {
    List<Album> albumList = [];

    if (docList == null) return null;

    docList.forEach((doc) {
      final elements = doc.findAllElements('album');
      if (elements.isNotEmpty) {
        albumList.addAll(elements.map((a) => Album.fromXML(a)).toList());
      }
    });
    final db = await database;
    await db.rawDelete('DELETE FROM $dbName');
    albumList.forEach((a) async {
      await db.insert(dbName, a.toMap());
    });
    return albumList;
  }

  Future<int> getArtistId(int albumId) async {
    final db = await database;
    final response =
        await db.rawQuery('SELECT artistId FROM $dbName WHERE id = "$albumId"');
    return response.first.values.first;
  }

  Future<List<Album>> getAlbumFromArtistId(int artistId) async {
    final db = await database;
    final response = await db.query(dbName, where: 'artistId = ?', whereArgs: [artistId]);
    return response.map((e) => Album.fromMap(e)).toList();
  }

  @override
  Future updateWithDoc(XML.XmlDocument doc) => throw UnimplementedError();
}
