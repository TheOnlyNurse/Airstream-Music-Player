import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/playlist_model.dart';

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
    return response.map((e) => Playlist.fromJSON(e)).toList();
  }

  @override
  Future updateWithDoc(Map<String, dynamic> json) {}

  @override
  Future updateWithDocList(List<Map<String, dynamic>> jsonList) =>
      throw UnimplementedError();
}
