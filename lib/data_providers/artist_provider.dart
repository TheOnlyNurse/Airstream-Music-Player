import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/artist_model.dart';

class ArtistProvider extends DatabaseProvider {
  @override
  String get dbName => 'artists';

  @override
  String get tableColumns => 'id TEXT primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'albumCount INTEGER,'
      'coverArt TEXT';

  ArtistProvider._internal();

  static final ArtistProvider _instance = ArtistProvider._internal();

  factory ArtistProvider() {
    return _instance;
  }

  Future getLibraryList() async {
    final db = await database;
    final response = await db.rawQuery('SELECT * FROM $dbName ORDER BY name ASC');
    List<Artist> list = response.map((a) => Artist.fromJSON(a)).toList();
    return list;
  }

  @override
  Future<List<Artist>> updateWithJson(Map<String, dynamic> json) async {
    final alphabeticalMapList = json['index'];
    final List<Artist> artistList = [];
    alphabeticalMapList.forEach((letter) => letter['artist'].forEach((map) {
          artistList.add(Artist.fromJSON(map));
        }));
    // Replace database with such data
    final db = await database;
    await db.rawDelete('DELETE FROM $dbName');
    artistList.forEach((a) async {
      await db.insert(dbName, a.toJSON());
    });
    return artistList;
  }

  Future queryArtistByName(String name) async {
    final List<Artist> artistList = [];
    final db = await database;
    final response =
        await db.query(dbName, where: 'name LIKE ?', whereArgs: ['%$name%'], limit: 5);
    if (response.isNotEmpty)
      artistList.addAll(response.map((e) => Artist.fromJSON(e)).toList());
    return artistList;
  }

  @override
  Future updateWithJsonList(List<Map<String, dynamic>> json) =>
      throw UnimplementedError();
}
