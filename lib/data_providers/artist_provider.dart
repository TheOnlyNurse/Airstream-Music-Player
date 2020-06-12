import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:xml/xml.dart' as xml;

class ArtistProvider extends DatabaseProvider {
  @override
  String get dbName => 'artists';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'albumCount INTEGER,'
      'art TEXT';

  ArtistProvider._internal();

  static final ArtistProvider _instance = ArtistProvider._internal();

  factory ArtistProvider() => _instance;

  final virtualCache = <Artist>[];

  Future<List<Artist>> getLibraryList() async {
    if (virtualCache.isNotEmpty) {
      return virtualCache;
    }

    final db = await database;
    final response = await db.query(dbName, orderBy: 'name ASC');

    if (response.isEmpty) {
      return _downloadArtists();
    } else {
      virtualCache.clear();
      virtualCache.addAll(response.map((a) => Artist.fromSQL(a)).toList());
      return virtualCache;
    }
  }

  Future<List<Artist>> _downloadArtists() async {
		final artistXml = await ServerProvider().fetchXML('getArtists?');
		if (artistXml != null) {
			virtualCache.clear();
			virtualCache.addAll(await _updateWithXml(artistXml));
			return virtualCache;
		} else {
			return null;
		}
  }

  Future<List<Artist>> _updateWithXml(xml.XmlDocument doc) async {
    final artistList =
        doc.findAllElements('artist').map((e) => Artist.fromServer(e)).toList();

    final db = await database;
    await db.delete(dbName);

    for (var artist in artistList) await db.insert(dbName, artist.toSQL());

    return artistList;
  }

	Future query({String name}) async {
		final db = await database;
		final response = await db.query(
			dbName,
			where: 'name LIKE ?',
			whereArgs: ['%$name%'],
			limit: 5,
		);

		if (response.isNotEmpty) {
			return response.map((e) => Artist.fromSQL(e)).toList();
		}
		return null;
  }
}
