import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as XML;

class ArtistsProvider extends DatabaseProvider {
  @override
  String get dbName => 'artists';

  @override
  Future<String> get directoryPath => getDatabasesPath();

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'albumCount INTEGER,'
      'coverArt TEXT';

  ArtistsProvider._internal();

  static final ArtistsProvider _instance = ArtistsProvider._internal();

  factory ArtistsProvider() {
    return _instance;
  }

  Future getLibraryList() async {
    final db = await database;
    final response = await db.rawQuery('SELECT * FROM $dbName ORDER BY name ASC');
    List<Artist> list = response.map((a) => Artist.fromMap(a)).toList();
    return list;
  }

  @override
  Future<List<Artist>> updateWithDoc(XML.XmlDocument doc) async {
    if (doc == null) return null;
    // Extract data
    final elements = doc.findAllElements('artist');
    final List<Artist> artistList = elements.map((a) => Artist.fromXML(a)).toList();
    // Replace database with such data
    final db = await database;
    await db.rawDelete('DELETE FROM $dbName');
    artistList.forEach((a) async {
      await db.insert(dbName, a.toMap());
    });
    return artistList;
  }

  @override
  Future updateWithDocList(List<XML.XmlDocument> docList) => throw UnimplementedError();
}
