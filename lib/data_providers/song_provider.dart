import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/models/song_model.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart' as xml;

class SongProvider extends DatabaseProvider {
  /// Global Functions
  ///
  /// Search the database for songs
  /// The search limit is per query, meaning a search limit of 5 with both title and artist
  /// specified will result in a total of 10 results.
  Future<ProviderResponse> query({
    String title,
    String artist,
    int albumId,
    int id,
    @required int searchLimit,
  }) async {
    assert(searchLimit != null);

    final db = await database;

    final queryArgs = <String, dynamic>{};
    if (title != null) {
      queryArgs['where'] = 'title LIKE ?';
      queryArgs['whereArgs'] = ['%$title%'];
    }
    if (artist != null) {
      queryArgs['where'] = 'artist LIKE ?';
      queryArgs['whereArgs'] = ['%$artist%'];
    }
    if (albumId != null) {
      queryArgs['where'] = 'albumId = ?';
      queryArgs['whereArgs'] = ['$albumId'];
    }
    if (id != null) {
      queryArgs['where'] = 'id = ?';
      queryArgs['whereArgs'] = ['$id'];
    }

    final response = await db.query(
      dbName,
      where: queryArgs['where'],
      whereArgs: queryArgs['whereArgs'],
      limit: searchLimit,
      orderBy: 'title ASC',
    );

    final songList = response.map((e) => Song.fromSQL(e)).toList();

    if (songList.isEmpty || songList.length < searchLimit) {
      ProviderResponse webResults;

      // Query the server for results
      if (albumId != null) webResults = await _downloadAlbumSongs(albumId);
      if (title != null) webResults = await _downloadSearch(title, searchLimit);
      if (artist != null) webResults = await _downloadSearch(artist, searchLimit);
      if (id != null) webResults = await _downloadId(id);

      // Web results don't have some locally made changes
      if (webResults.status == DataStatus.ok) {
        assert(webResults.data is List<Song>);
        for (Song song in webResults.data) {
          if (!songList.contains(song)) songList.add(song);
        }
      }

      // Fallback on songlist if the server is unresponsive
      if (songList.isNotEmpty) {
        return _checkOnlineStatus(ProviderResponse(
          status: DataStatus.ok,
          data: songList,
        ));
      } else {
        return ProviderResponse(
          status: DataStatus.error,
          source: ProviderSource.song,
          message: 'no songs found on server',
        );
      }
    } else {
      return _checkOnlineStatus(ProviderResponse(status: DataStatus.ok, data: songList));
    }
  }

  Future<ProviderResponse> getStarred() async {
    final db = await database;
    final response = await db.query(dbName, where: 'isStarred = ?', whereArgs: ['1']);
    if (response.isEmpty) {
      return await _downloadStarred();
    } else {
      final artistList = response.map((e) => Song.fromSQL(e)).toList();
      return _checkOnlineStatus(
        ProviderResponse(status: DataStatus.ok, data: artistList),
      );
    }
  }

  Future<ProviderResponse> forceUpdateStarred() async {
    if (await SettingsProvider().isOffline) {
      return getStarred();
    } else {
      final db = await database;
      // Clear all records of starred songs in favour of online version
      db.rawUpdate('UPDATE $dbName SET isStarred = ? WHERE isStarred = ?', [0, 1]);
      return _downloadStarred();
    }
  }

	Future<Null> changeStars(List<Song> songList, bool toStar) async {
    final db = await database;
    final dbValue = toStar ? 1 : 0;
    var request = toStar ? 'star?' : 'unstar?';
    for (Song song in songList) {
      request += '&id=${song.id}';
      await db.rawUpdate(
        'UPDATE $dbName SET isStarred = ? WHERE id = ?',
        [dbValue, song.id],
      );
    }
    Scheduler().schedule(request);
    return;
  }

  /// Private Functions
  ///
  /// Update songs from an XML document
  Future<List<Song>> _updateWithXml(xml.XmlDocument doc, {bool isStarred = false}) async {
    final songList = doc
        .findAllElements('song')
        .map((e) => Song.fromServer(e, isStarred: isStarred))
        .toList();
    // if isStarred, replace current information
    final algorithm = isStarred ? ConflictAlgorithm.replace : ConflictAlgorithm.ignore;

    final db = await database;
    for (var song in songList) {
      await db.insert(dbName, song.toSQL(), conflictAlgorithm: algorithm);
    }
    return songList;
  }

  Future<ProviderResponse> _checkOnlineStatus(ProviderResponse songResponse) async {
    if (songResponse.status == DataStatus.error) return songResponse;
    assert(songResponse.data is List<Song>);

    if (await SettingsProvider().isOffline) {
      final cachedList = <Song>[];
      final offlineList = await AudioCacheProvider().getCachedList(songs: true);

      if (offlineList.status == DataStatus.error) return offlineList;
      assert(offlineList.data is List<int>);

      for (Song song in songResponse.data) {
        if (offlineList.data.contains(song.id)) cachedList.add(song);
      }

      if (cachedList.isEmpty) {
        return ProviderResponse(
          status: DataStatus.error,
          source: ProviderSource.song,
          message: 'no cached songs',
        );
      } else {
        return ProviderResponse(status: DataStatus.ok, data: cachedList);
      }
    }

    return ProviderResponse(status: DataStatus.ok, data: songResponse.data);
  }

  Future<ProviderResponse> _downloadStarred() async {
    final xmlDoc = await ServerProvider().fetchRequest('getStarred2?', FetchType.xmlDoc);
    if (xmlDoc.status == DataStatus.error) return xmlDoc;
    assert(xmlDoc.data is xml.XmlDocument);

    final songList = await _updateWithXml(xmlDoc.data, isStarred: true);
    return ProviderResponse(status: DataStatus.ok, data: songList);
  }

  Future<ProviderResponse> _downloadSearch(String query, int soundCount) async {
    final xmlDoc = await ServerProvider().fetchRequest(
      'search3?query=$query&songCount=$soundCount&artistCount=0&albumCount=0',
      FetchType.xmlDoc,
    );

    if (xmlDoc.status == DataStatus.error) return xmlDoc;
    assert(xmlDoc.data is xml.XmlDocument);

    final songList = await _updateWithXml(xmlDoc.data);
    songList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    if (songList.isEmpty) {
      return ProviderResponse(
        status: DataStatus.error,
        source: ProviderSource.song,
        message: 'found no songs under $query',
      );
    } else {
      return ProviderResponse(status: DataStatus.ok, data: songList);
    }
  }

  Future<ProviderResponse> _downloadAlbumSongs(int albumId) async {
    final xmlDoc = await ServerProvider().fetchRequest(
      'getAlbum?id=$albumId&',
      FetchType.xmlDoc,
    );

    if (xmlDoc.status == DataStatus.error) return xmlDoc;
    assert(xmlDoc.data is xml.XmlDocument);

    final songList = await _updateWithXml(xmlDoc.data);
    songList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    if (songList.isEmpty) {
      return ProviderResponse(
        status: DataStatus.error,
        source: ProviderSource.song,
        message: 'found no songs in album',
      );
    } else {
      return ProviderResponse(status: DataStatus.ok, data: songList);
    }
  }

  Future<ProviderResponse> _downloadId(int id) async {
    final xmlDoc = await ServerProvider().fetchRequest(
      'getSong?id=$id&',
      FetchType.xmlDoc,
    );

    if (xmlDoc.status == DataStatus.error) return xmlDoc;
    assert(xmlDoc.data is xml.XmlDocument);

    final list = await _updateWithXml(xmlDoc.data);

    if (list.isEmpty) {
      return ProviderResponse(
        status: DataStatus.error,
        source: ProviderSource.song,
        message: 'found no songs with id: $id',
      );
    } else {
      return ProviderResponse(status: DataStatus.ok, data: list);
    }
  }

  /// Database provider required overrides
  @override
  String get dbName => 'songs';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'title TEXT NOT NULL,'
      'album TEXT,'
      'artist TEXT,'
      'art TEXT,'
      'albumId INTEGER,'
      'isStarred INTEGER';

  /// Singleton boilerplate code
  SongProvider._internal();

  static final SongProvider _instance = SongProvider._internal();

  factory SongProvider() => _instance;
}
