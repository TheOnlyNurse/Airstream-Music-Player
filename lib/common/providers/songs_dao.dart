import 'package:moor/moor.dart';
import 'package:xml/xml.dart';

/// Internal Links
import 'moor_database.dart';
import '../providers/moor_database.dart';

part 'songs_dao.g.dart';

class Songs extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get album => text()();

  TextColumn get artist => text()();

  TextColumn get art => text().nullable()();

  IntColumn get albumId => integer()();

  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();

  TextColumn get topSongKey => text().nullable()();

  TextColumn get filename => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [Songs])
class SongsDao extends DatabaseAccessor<MoorDatabase> with _$SongsDaoMixin {
  SongsDao(MoorDatabase db) : super(db);

  /// ========== QUERYING ==========

  /// Returns a song list given a list of ids.
  Future<List<Song>> idList(List<int> idList) async {
    final songList = select(songs)..where((tbl) => tbl.id.isIn(idList));
    return songList.get();
  }

  /// Searches for song by id.
  Future<Song> id(int id) async {
    final query = select(songs)..where((tbl) => tbl.id.equals(id));
    return query.getSingle();
  }

  /// Returns songs that have a matching features.album id.
  Future<List<Song>> album(int albumId) {
    final query = select(songs)..where((tbl) => tbl.albumId.equals(albumId));
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.get();
  }

  /// Returns a song list by a title query
  Future<List<Song>> title(String title) {
    final query = select(songs)..where((tbl) => tbl.title.like('%$title%'));
    return query.get();
  }

  /// Returns a song list by artist name query
  Future<List<Song>> artistName(String artist) {
    final query = select(songs)..where((tbl) => tbl.artist.like('%$artist%'));
    return query.get();
  }

  /// Returns songs that are marked as isStarred: true.
  Future<List<Song>> starred() {
    var query = select(songs)..where((tbl) => tbl.isStarred.equals(true));
    return query.get();
  }

  /// Returns top songs of a given artist name.
  Future<List<Song>> topSongs(String artistName) {
    var keys = List.generate(5, (index) => '$index.$artistName');
    var query = select(songs)..where((tbl) => tbl.topSongKey.isIn(keys));
    query.orderBy([(t) => OrderingTerm(expression: t.topSongKey)]);
    return query.get();
  }

  /// ========== DB MANAGEMENT ==========

  Future<void> insertElements(List<XmlElement> elements) {
    return batch((batch) {
      var companions = elements.map(_elementToCompanion).toList();
      batch.insertAll(songs, companions, mode: InsertMode.insertOrIgnore);
    });
  }

  /// Changes all songs with isStarred: true to false.
  Future<void> clearStarred() {
    return batch((batch) {
      batch.update(
        songs,
        SongsCompanion(isStarred: const Value(false)),
        where: (t) => t.isStarred.equals(true),
      );
    });
  }

  /// Updates songs (by a given id list) to have given a isStarred value.
  Future<void> updateStarred(List<int> idList, {isStarred = true}) {
    return batch((batch) {
      batch.update(
        songs,
        SongsCompanion(isStarred: Value(isStarred)),
        where: (t) => t.id.isIn(idList),
      );
    });
  }

  /// Marks a given list of song ids with an artist's name.
  Future<void> markTopSongs(String artistName, List<int> idList) {
    return batch((batch) {
      for (var index = 0; index < idList.length; index++) {
        final id = idList[index];
        final key = '$index.$artistName';
        batch.update(
          songs,
          SongsCompanion(topSongKey: Value(key)),
          where: (t) => t.id.equals(id),
        );
      }
    });
  }

  /// Parses an xml element into a companion for database insertion
  SongsCompanion _elementToCompanion(XmlElement element) {
    return SongsCompanion.insert(
      id: Value(int.parse(element.getAttribute('id'))),
      title: element.getAttribute('title'),
      artist: element.getAttribute('artist'),
      album: element.getAttribute('features.album'),
      art: Value(element.getAttribute('coverArt')),
      albumId: _parseAsInt(element.getAttribute('albumId')),
    );
  }

  /// Either parses a string or returns null if the object is null
  int _parseAsInt(String attribute) {
    return attribute == null ? null : int.parse(attribute);
  }
}
