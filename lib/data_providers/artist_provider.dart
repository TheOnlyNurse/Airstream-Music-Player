import 'package:airstream/data_providers/album_provider.dart';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
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

  Future<List<Artist>> getLibraryList() async {
    final db = await database;
    final response = await db.query(dbName, orderBy: 'name ASC');

    if (response.isEmpty)
      return _checkOnlineStatus(await _downloadArtists());
    else
      return _checkOnlineStatus(response.map((a) => Artist.fromSQL(a)).toList());
  }

  Future<List<Artist>> _downloadArtists() async {
    final artistXml = await ServerProvider().fetchXML('getArtists?');
    if (artistXml != null)
      return _updateWithXml(artistXml);
    else
      return null;
  }

  Future<List<Artist>> _updateWithXml(xml.XmlDocument doc) async {
    final artistList =
        doc.findAllElements('artist').map((e) => Artist.fromServer(e)).toList();

    final db = await database;
    await db.delete(dbName);

    for (var artist in artistList) await db.insert(dbName, artist.toSQL());

    return artistList;
  }

  Future<List<Artist>> query({String name}) async {
    final db = await database;
    final response = await db.query(
      dbName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      limit: 5,
    );

    if (response.isNotEmpty)
      return _checkOnlineStatus(response.map((e) => Artist.fromSQL(e)).toList());

    return null;
  }

  Future<List<Artist>> _checkOnlineStatus(List<Artist> artistList) async {
    if (artistList.isEmpty || artistList == null) return null;

    if (await SettingsProvider().isOffline) {
      final cachedList = <Artist>[];
      final albumList = await AlbumProvider().getLibraryList();

      if (albumList == null) return null;

      final artistIdList = albumList.map((a) => a.artistId).toList();

      for (var artist in artistList) {
        if (artistIdList.contains(artist.id)) cachedList.add(artist);
      }

      if (cachedList.isEmpty) return null;
      return cachedList;
    }

    return artistList;
  }
}
