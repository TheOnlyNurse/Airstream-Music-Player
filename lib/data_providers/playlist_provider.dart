import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:sqflite/sqflite.dart';

class PlaylistProvider extends DatabaseProvider {
  @override
  String get dbName => 'playlists';

  @override
  String get tableColumns => 'id TEXT primary key NOT NULL,'
      'name TEXT NOT NULL,'
      'comment TEXT,'
      'date TEXT,'
      'songList TEXT';

  @override
  Future<List<Playlist>> getLibraryList() async {
    final db = await database;
    final response = await db.query(dbName);
    if (response.isEmpty) return null;
    return response.map((e) => Playlist.fromDatabase(e)).toList();
  }

  /// Update one playlist from a json map
  ///
  /// The information required to make a playlist class requires going through each
  /// playlist individually and the acquiring the song ids. Therefore, you can only "update"
  /// one playlist at a time.
  @override
  Future<Playlist> updateWithJson(Map<String, dynamic> json) async {
    final playlist = Playlist.fromServer(json);
    final db = await database;
    await db.insert(
      dbName,
      playlist.toDatabase(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return playlist;
  }

  Future<Null> clearDbForUpdate() async {
    final db = await database;
    await db.delete(dbName);
    return;
  }

  Future<List<String>> addSongList(Map<String, dynamic> json) async {
    final List<String> songs = json['entry'].map((s) => s['id']).toList();
    final db = await database;
    await db
        .rawUpdate('UPDATE $dbName SET songList = ? WHERE id = ?', [songs, json['id']]);
    return songs;
  }

  @override
  Future updateWithJsonList(List<Map<String, dynamic>> jsonList) =>
      throw UnimplementedError();
}
