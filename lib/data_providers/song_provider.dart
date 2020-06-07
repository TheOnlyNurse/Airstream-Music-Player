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
    final response = await db
        .rawQuery('SELECT * FROM $dbName WHERE albumId = "$id" ORDER BY title ASC');
    final List<Song> list = response.map((a) => Song.fromJSON(a)).toList();
    return list;
  }

  /// Update songs from an XML document
  ///
  /// Starred Songs (the library listing) can be updated multiple times. Thus if the XML
  /// document is one from a Starred Songs list, the already cached Starred Songs need
  /// to be update (easiest way being deleting and inserting).
  @override
  Future<List<Song>> updateWithDoc(Map<String, dynamic> json, {isStarred = true}) async {
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
        db.insert(dbName, a.toJSONAsStarred(isStarred: isStarred),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
    // All other songs are inserted when encountered in their albums. If the song exists,
    // usually because it is in a playlist or starred then it is ignored.
    songList.forEach((a) => db.insert(
          dbName,
          a.toJSONAsStarred(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        ));
    return songList;
  }

  @override
  Future updateWithDocList(List<Map<String, dynamic>> jsonList) =>
      throw UnimplementedError();
}
