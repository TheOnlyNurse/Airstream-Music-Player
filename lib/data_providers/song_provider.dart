import 'package:airstream/data_providers/database_provider.dart';
import 'package:airstream/models/song_model.dart';
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
  Future<List<Song>> querySongs({
    String title,
    String artist,
    int albumId,
    int id,
    int searchLimit = 5,
  }) async {
    final songList = <Song>[];
    final db = await database;
    if (title != null) {
      final response = await db.query(
        dbName,
        where: 'title LIKE ?',
        whereArgs: ['%$title%'],
        limit: searchLimit,
      );
      songList.addAll(response.map((e) => Song.fromSQL(e)).toList());
    }
    if (artist != null) {
      final response = await db.query(
        dbName,
        where: 'artist LIKE ?',
        whereArgs: ['%$artist%'],
        limit: searchLimit,
      );
      songList.addAll(response.map((e) => Song.fromSQL(e)).toList());
    }
    if (id != null) {
      final response = await db.query(
        dbName,
        where: 'id = ?',
        whereArgs: [id],
        limit: searchLimit,
      );
      songList.addAll(response.map((e) => Song.fromSQL(e)).toList());
    }
    if (albumId != null) {
      final response = await db.query(
        dbName,
        where: 'albumId = ?',
        whereArgs: [albumId],
        orderBy: 'title ASC',
        limit: searchLimit,
      );
      songList.addAll(response.map((e) => Song.fromSQL(e)).toList());
    }
    return songList;
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
}
