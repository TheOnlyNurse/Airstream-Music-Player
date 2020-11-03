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

  TextColumn get filename => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [Songs])
class SongsDao extends DatabaseAccessor<MoorDatabase> with _$SongsDaoMixin {
  SongsDao(MoorDatabase db) : super(db);

  /// ========== QUERYING ==========

  /// Returns a song list given a list of ids.
  Future<List<Song>> byIdList(List<int> idList) async {
    final songList = select(songs)..where((tbl) => tbl.id.isIn(idList));
    return songList.get();
  }

  /// Searches for song by id.
  Future<Song> byId(int id) async {
    final query = select(songs)..where((tbl) => tbl.id.equals(id));
    return query.getSingle();
  }

  /// Returns songs that have a matching album id.
  Future<List<Song>> byAlbum(int albumId) {
    final query = select(songs);
    query.where((tbl) => tbl.albumId.equals(albumId));
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.get();
  }

  /// Returns a song list by a title query
  Future<List<Song>> byTitle(String title) {
    final query = select(songs);
    query.where((tbl) => tbl.title.like('%$title%'));
    return query.get();
  }

  /// Returns a song list by artist name query
  Future<List<Song>> byArtistName(String artist) {
    final query = select(songs);
    query.where((tbl) => tbl.artist.like('%$artist%'));
    return query.get();
  }

  /// ========== DB MANAGEMENT ==========

  Future<void> insertElements(List<XmlElement> elements) {
    return batch((batch) {
      var companions = elements.map(_elementToCompanion).toList();
      batch.insertAll(songs, companions, mode: InsertMode.insertOrIgnore);
    });
  }

  /// Parses an xml element into a companion for database insertion
  SongsCompanion _elementToCompanion(XmlElement element) {
    return SongsCompanion.insert(
      id: Value(int.parse(element.getAttribute('id'))),
      title: element.getAttribute('title'),
      artist: element.getAttribute('artist'),
      album: element.getAttribute('album'),
      art: Value(element.getAttribute('coverArt')),
      albumId: _parseAsInt(element.getAttribute('albumId')),
    );
  }

  /// Either parses a string or returns null if the object is null
  int _parseAsInt(String attribute) {
    return attribute == null ? null : int.parse(attribute);
  }


}
