import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/song_model.dart';
import 'package:sqflite/sqflite.dart';

class SongProvider extends DatabaseProvider {
  @override
  String get dbName => 'songs';

  @override
  String get tableColumns => 'id TEXT primary key NOT NULL,'
      'title TEXT NOT NULL,'
      'album TEXT,'
      'artist TEXT,'
      'coverArt TEXT,'
      'albumId TEXT,'
      'artistID TEXT,'
      'starred INTEGER';

  SongProvider._internal();

  static final SongProvider _instance = SongProvider._internal();

  factory SongProvider() => _instance;

  Future<List<Song>> getLibraryList() async {
    final db = await database;
    final response =
        await db.rawQuery('SELECT * FROM $dbName WHERE starred = 1 ORDER BY title ASC');
    List<Song> list = response.map((a) => Song.fromJSON(a)).toList();
    return list;
  }

  /// Get songs from album id
  ///
  /// This function doesn't return null, only an empty list.
  Future<List<Song>> getSongsFromAlbumId(String id) async {
    final db = await database;
    final response = await db.query(
      dbName,
      where: 'albumId = ?',
      whereArgs: [id],
      orderBy: 'title ASC',
    );
    final List<Song> list = response.map((a) => Song.fromJSON(a)).toList();
    return list;
  }

  /// Gets songs from id list
  Future<List<Song>> getSongsByIds(List<String> idList) async {
    final List<Song> songList = [];
    final db = await database;
    for (var id in idList) {
      final response = await db.query(dbName, where: 'id = ?', whereArgs: [id]);
      if (response.isNotEmpty) songList.add(Song.fromJSON(response.first));
    }
    return songList;
  }

  Future<List<Song>> querySongsByTitle(String title) async {
    final List<Song> songList = [];
    final db = await database;
    final response =
        await db.query(dbName, where: 'title LIKE ?', whereArgs: ['%$title%'], limit: 5);
    if (response.isNotEmpty)
      songList.addAll(response.map((e) => Song.fromJSON(e)).toList());
    return songList;
  }

  /// Update songs from an XML document
  ///
  /// Starred Songs (the library listing) can be updated multiple times. Thus if the XML
  /// document is one from a Starred Songs list, the already cached Starred Songs need
  /// to be update (easiest way being deleting and inserting).
  @override
  Future<List<Song>> updateWithJson(Map<String, dynamic> json, {isStarred = true}) async {
    final elements = json['song'];
    final List<Song> songList = [];
    elements.forEach((a) => songList.add(Song.fromJSON(a)));

    final db = await database;
    // Starred songs are all deleted then the new list inserted
    if (isStarred) {
      await db.delete(dbName, where: 'starred = ?', whereArgs: [1]);
      songList.forEach((a) {
        // If a starred item was first encountered somewhere other than in the starred library
        // replace that with this entry (the difference being one this one is starred).
				db.insert(dbName, a.toJson(isStarred: isStarred),
						conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
		// All other songs are inserted when encountered in their albums. If the song exists,
		// usually because it is in a playlist or starred then it is ignored.
		songList.forEach((a) =>
				db.insert(
					dbName,
					a.toJson(),
					conflictAlgorithm: ConflictAlgorithm.ignore,
				));
		return songList;
	}

	Future<Song> addSongFromJson(Map<String, dynamic> json) async {
		final song = Song.fromJSON(json);
		final db = await database;
		await db.insert(
			dbName,
			song.toJson(),
			conflictAlgorithm: ConflictAlgorithm.ignore,
		);
		return song;
	}

	@override
	Future updateWithJsonList(List<Map<String, dynamic>> jsonList) =>
			throw UnimplementedError();
}
