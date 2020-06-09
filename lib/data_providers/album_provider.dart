import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/album_model.dart';

class AlbumProvider extends DatabaseProvider {
  @override
  String get dbName => 'albums';

  @override
  String get tableColumns => 'id TEXT primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'artist TEXT,'
      'artistId TEXT,'
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
		List<Album> list = response.map((a) => Album.fromJSON(a)).toList();
		return list;
	}

	@override
	Future<List<Album>> updateWithJsonList(List<Map<String, dynamic>> jsonList) async {
		List<Album> albumList = [];

		jsonList.forEach((json) {
			final elements = json['album'];
			elements.forEach((a) => albumList.add(Album.fromJSON(a)));
		});
		final db = await database;
		await db.rawDelete('DELETE FROM $dbName');
		albumList.forEach((a) async {
			await db.insert(dbName, a.toJSON());
		});
		return albumList;
	}

	Future<int> getArtistId(int albumId) async {
		final db = await database;
		final response =
		await db.rawQuery('SELECT artistId FROM $dbName WHERE id = "$albumId"');
		return response.first.values.first;
	}

	Future<List<Album>> getAlbumFromArtistId(String artistId) async {
		final db = await database;
		final response = await db.query(dbName, where: 'artistId = ?', whereArgs: [artistId]);
		return response.map((e) => Album.fromJSON(e)).toList();
	}

	@override
	Future updateWithJson(Map<String, dynamic> json) => throw UnimplementedError();
}
