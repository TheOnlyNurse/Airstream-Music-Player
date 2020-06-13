import 'package:airstream/data_providers/audio_cache_provider.dart';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/song_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as xml;

class SongProvider extends DatabaseProvider {
  @override
  String get dbName => 'songs';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'title TEXT NOT NULL,'
      'album TEXT,'
      'artist TEXT,'
      'art TEXT,'
      'albumId INTEGER,'
      'artistID INTEGER';

  SongProvider._internal();

  static final SongProvider _instance = SongProvider._internal();

  factory SongProvider() => _instance;

  /// Search the database for songs
  ///
  /// The search limit is per query, meaning a search limit of 5 with both title and artist
  /// specified will result in a total of 10 results.
  Future<List<Song>> query({
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
    List<Song> webResults;

    if (songList.isEmpty || songList.length < searchLimit) {
      // Query the server for results
      if (albumId != null) webResults = await _downloadAlbumSongs(albumId);
      if (title != null) webResults = await _downloadSearch(title, searchLimit);
      if (id != null) webResults = await _downloadId(id);
      // Fallback on songlist if the server is unresponsive
      if (webResults != null) return webResults;
      if (songList.isNotEmpty) return _checkOnlineStatus(songList);
      return null;
    } else {
      return _checkOnlineStatus(songList);
    }
  }

  /// Update songs from an XML document
  Future<List<Song>> updateWithXml(xml.XmlDocument doc) async {
    final songList = doc.findAllElements('song').map((e) => Song.fromServer(e)).toList();

    final db = await database;
    for (var song in songList) {
      await db.insert(dbName, song.toSQL(), conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    return songList;
  }

  Future<List<Song>> _checkOnlineStatus(List<Song> songList) async {
    if (songList.isEmpty || songList == null) return null;

    if (await SettingsProvider().isOffline) {
      final cachedList = <Song>[];
      final offlineList = await AudioCacheProvider().getCachedList(songs: true);

      if (offlineList == null) return null;

      for (var song in songList) {
        if (offlineList.contains(song.id)) cachedList.add(song);
      }

      if (cachedList.isEmpty) return null;
      return cachedList;
    }

    return songList;
  }

  Future<List<Song>> _downloadSearch(String query, int soundCount) async {
    final xmlDoc = await ServerProvider().fetchXML(
        'search3?query=$query&songCount=$soundCount&artistCount=0&albumCount=0');

    if (xmlDoc == null) return null;

    final songList = await updateWithXml(xmlDoc);
    songList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    if (songList.isEmpty) return null;

    return songList;
  }

  Future<List<Song>> _downloadAlbumSongs(int albumId) async {
    final xmlDoc = await ServerProvider().fetchXML('getAlbum?id=$albumId&');
    if (xmlDoc == null) {
      return null;
    }
    final songList = await updateWithXml(xmlDoc);
    songList.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    if (songList.isEmpty) {
      return null;
    }
    return songList;
  }

  Future<List<Song>> _downloadId(int id) async {
    final xmlDoc = await ServerProvider().fetchXML('getSong?id=$id&');
    if (xmlDoc == null) {
      return null;
    }
    final list = await updateWithXml(xmlDoc);
    if (list.isEmpty) {
      return null;
    }
    return [list.first];
  }
}
