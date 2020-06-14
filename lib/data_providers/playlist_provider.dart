import 'dart:async';

import 'package:airstream/data_providers/audio_cache_provider.dart';
import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/models/song_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as xml;

class PlaylistProvider extends DatabaseProvider {
  /// Global variables
  StreamController<PlaylistDatabase> onChangeController = StreamController.broadcast();

  /// Global Functions
  Future<ProviderResponse> library() async {
    final db = await database;
    final response = await db.query(dbName, orderBy: 'name ASC');

    if (response.isEmpty) return _checkOnlineState(await _downloadPlaylists());

    final playlistArray = response.map((e) => Playlist.fromSQL(e)).toList();
    return _checkOnlineState(
      ProviderResponse(status: DataStatus.ok, data: playlistArray),
    );
  }

  Future<Null> removeSong(int id, int removeIndex) async {
    final db = await database;
    final response = await db.query(dbName, where: 'id = ?', whereArgs: [id]);
    assert(response.isNotEmpty);
    final playlist = response.map((e) => Playlist.fromSQL(e)).toList().first;
    playlist.songIds.removeAt(removeIndex);
    await db.update(dbName, playlist.toSQL(), where: 'id = ?', whereArgs: [id]);
    onChangeController.add(PlaylistDatabase.songRemoved);
    return;
  }

  /// Private Functions
  Future<ProviderResponse> _checkOnlineState(ProviderResponse listResponse) async {
    if (listResponse.status == DataStatus.error) return listResponse;
    assert(listResponse.data is List<Playlist>);

    if (await SettingsProvider().isOffline) {
      final cachedList = <Playlist>[];
      final offlineSongs = await AudioCacheProvider().getCachedList(songs: true);

      if (offlineSongs.status == DataStatus.error) return offlineSongs;
      assert(offlineSongs.data is List<int>);

      for (Playlist playlist in listResponse.data) {
        for (int songId in offlineSongs.data) {
          if (playlist.songIds.contains(songId)) {
            cachedList.add(playlist);
            break;
          }
        }
      }

      if (cachedList.isEmpty) {
        return ProviderResponse(
          status: DataStatus.error,
          source: ProviderSource.playlist,
          message: 'no cached playlists',
        );
      } else {
        return ProviderResponse(status: DataStatus.ok, data: cachedList);
      }
    }

    return ProviderResponse(status: DataStatus.ok, data: listResponse.data);
  }

  Future<ProviderResponse> _downloadPlaylists() async {
    final response = await ServerProvider().fetchRequest(
      'getPlaylists?',
      FetchType.xmlDoc,
    );

    if (response.status == DataStatus.error) return response;
    assert(response.data is xml.XmlDocument);

    await (await database).delete(dbName);

    final playlistArray = <Playlist>[];
    final idList = response.data
        .findAllElements('playlist')
        .map((element) => element.getAttribute('id'));

    for (var id in idList) {
      final singlePlaylist = await ServerProvider().fetchRequest(
        'getPlaylist?id=$id',
        FetchType.xmlDoc,
      );

      if (singlePlaylist.status == DataStatus.error) break;
      assert(singlePlaylist.data is xml.XmlDocument);

      playlistArray.add(await _updateWithXml(singlePlaylist.data));
    }

    if (playlistArray.isEmpty) {
      return ProviderResponse(
        status: DataStatus.error,
        source: ProviderSource.playlist,
        message: 'found no playlists on server',
      );
    } else {
      onChangeController.add(PlaylistDatabase.fetched);
      return ProviderResponse(status: DataStatus.ok, data: playlistArray);
    }
  }

  /// Update one playlist from a json map
  ///
  /// The information required to make a playlist class requires going through each
  /// playlist individually and the acquiring the song ids. Therefore, you can only "update"
  /// one playlist at a time.
  Future<Playlist> _updateWithXml(xml.XmlDocument playlistXml) async {
    final playlist = Playlist.fromServer(playlistXml);
    final db = await database;
    await db.insert(
      dbName,
      playlist.toSQL(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return playlist;
  }

  /// Database Provider required overrides
  @override
  String get dbName => 'playlists';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'comment TEXT,'
      'date TEXT,'
      'songIds TEXT';

  /// Singleton Boilerplate
  PlaylistProvider._internal();

  static final PlaylistProvider _instance = PlaylistProvider._internal();

  factory PlaylistProvider() => _instance;
}

enum StarredType { songs, albums, artists }

enum PlaylistDatabase { songRemoved, fetched }