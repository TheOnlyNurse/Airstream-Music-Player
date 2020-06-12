import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/song_provider.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xml/xml.dart' as xml;

class PlaylistProvider extends DatabaseProvider {
  @override
  String get dbName => 'playlists';

  @override
  String get tableColumns => 'id INTEGER primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'comment TEXT,'
      'date TEXT,'
      'songIds TEXT';

  PlaylistProvider._internal();

  static final PlaylistProvider _instance = PlaylistProvider._internal();

  factory PlaylistProvider() => _instance;

  Future<List<dynamic>> getStarred(StarredType type) async {
    final db = await database;
    switch (type) {
      case StarredType.songs:
        final response = await db.query(dbName, where: 'id = ?', whereArgs: [-1]);
        if (response.isEmpty) return _downloadStarred(type);
        final playlist = Playlist.fromSQL(response.first);
        final songList = <Song>[];
        for (var id in playlist.songIds) {
          final list = await SongProvider().query(id: id, searchLimit: 1);
          if (list.isNotEmpty) songList.add(list.first);
        }
        return songList;
        break;
      case StarredType.albums:
        throw UnimplementedError();
        break;
      case StarredType.artists:
        throw UnimplementedError();
        break;
      default:
        return null;
    }
  }

  Future<List<dynamic>> _downloadStarred(StarredType type) async {
    final starredXml = await ServerProvider().fetchXML('getStarred2?');
    if (starredXml != null) {
      final db = await database;
      final songList = await SongProvider().updateWithXml(starredXml);
      final songIds = songList.map((song) => song.id).toList();
      db.insert(
        dbName,
        {'id': -1, 'name': 'starredSongs', 'songIds': songIds.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (type == StarredType.songs) return songList;
    }
    return null;
  }

  Future<List<Playlist>> getLibraryList() async {
    final db = await database;
    final response = await db.query(dbName, where: 'id > ?', whereArgs: [-1]);
    if (response.isEmpty) return _downloadPlaylists();
    final playlistArray = response.map((e) => Playlist.fromSQL(e)).toList();
    playlistArray.sort((a, b) => a.name.compareTo(b.name));
    return playlistArray;
  }

  Future<List<Playlist>> _downloadPlaylists() async {
    final allPlaylistsXml = await ServerProvider().fetchXML('getPlaylists?');
    if (allPlaylistsXml != null) {
      await (await database).delete(dbName);

      final playlistArray = <Playlist>[];
      final idList = allPlaylistsXml
          .findAllElements('playlist')
          .map((element) => element.getAttribute('id'));
      for (var id in idList) {
        final playlistXml = await ServerProvider().fetchXML('getPlaylist?id=$id');
        playlistArray.add(await _updateWithXml(playlistXml));
      }
      return playlistArray;
    }
    return null;
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
}

enum StarredType { songs, albums, artists }
