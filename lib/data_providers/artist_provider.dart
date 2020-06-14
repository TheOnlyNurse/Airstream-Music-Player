import 'package:airstream/data_providers/album_provider.dart';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:xml/xml.dart' as xml;

class ArtistProvider extends DatabaseProvider {
  /// Global Functions
  Future<ProviderResponse> library() async {
    final db = await database;
    final response = await db.query(dbName, orderBy: 'name ASC');

    if (response.isEmpty) {
      return _checkOnlineStatus(await _downloadArtists());
    } else {
      final artistList = response.map((a) => Artist.fromSQL(a)).toList();

      return _checkOnlineStatus(ProviderResponse(
        status: DataStatus.ok,
        data: artistList,
      ));
    }
  }

  Future<ProviderResponse> query({String name}) async {
    final db = await database;
    final response = await db.query(
      dbName,
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
      limit: 5,
    );

    if (response.isNotEmpty) {
      final artistList = response.map((e) => Artist.fromSQL(e)).toList();
      return _checkOnlineStatus(ProviderResponse(
        status: DataStatus.ok,
        data: artistList,
      ));
    }

    return ProviderResponse(
      status: DataStatus.error,
      source: ProviderSource.artist,
      message: 'did not find query $name',
    );
  }

  /// Private Functions
  Future<ProviderResponse> _downloadArtists() async {
    final response = await ServerProvider().fetchRequest('getArtists?', FetchType.xmlDoc);
    if (response.status == DataStatus.error) return response;
    assert(response.data is xml.XmlDocument);

    final artistList = await _updateWithXml(response.data);
    if (artistList.isEmpty) {
      return ProviderResponse(
        status: DataStatus.error,
        source: ProviderSource.artist,
        message: 'no artists found on server',
      );
    } else {
      return ProviderResponse(status: DataStatus.ok, data: artistList);
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

  Future<ProviderResponse> _checkOnlineStatus(ProviderResponse artistResponse) async {
    if (artistResponse.status == DataStatus.error) return artistResponse;
    assert(artistResponse.data is List<Artist>);

    if (await SettingsProvider().isOffline) {
      final cachedList = <Artist>[];
      final albumResponse = await AlbumProvider().library();

      if (albumResponse.status == DataStatus.error) return albumResponse;
      assert(albumResponse.data is List<Album>);

      final artistIdList = albumResponse.data.map((item) => item.artistId).toList();

      for (var artist in artistResponse.data) {
        if (artistIdList.contains(artist.id)) cachedList.add(artist);
      }

      if (cachedList.isEmpty) {
        return ProviderResponse(
          status: DataStatus.error,
          source: ProviderSource.artist,
          message: 'no cached artists',
        );
      } else {
        return ProviderResponse(status: DataStatus.ok, data: cachedList);
      }
    }

    return ProviderResponse(status: DataStatus.ok, data: artistResponse.data);
  }

  /// Database provider overrides
  @override
  String get dbName => 'artists';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'albumCount INTEGER,'
      'art TEXT';

  /// Singleton boilerplate code
  ArtistProvider._internal();

  static final ArtistProvider _instance = ArtistProvider._internal();

  factory ArtistProvider() => _instance;
}
