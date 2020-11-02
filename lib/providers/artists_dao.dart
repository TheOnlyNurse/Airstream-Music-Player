/// External Packages
import 'package:moor/moor.dart';
import 'package:xml/xml.dart';

/// Internal Links
import 'moor_database.dart';
import '../providers/moor_database.dart';

part 'artists_dao.g.dart';

class Artists extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  IntColumn get albumCount => integer()();

  TextColumn get art => text().nullable()();

  BlobColumn get similar => blob().nullable()();

  BlobColumn get topSongs => blob().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [Artists])
class ArtistsDao extends DatabaseAccessor<MoorDatabase> with _$ArtistsDaoMixin {
  /// So that the main database can create an instance of this dao
  ArtistsDao(MoorDatabase db) : super(db);

  /// ========== QUERYING ==========

  /// Returns artists by alphabetically name
  Future<List<Artist>> byAlphabet() {
    final query = select(artists);
    query.orderBy([(a) => OrderingTerm(expression: a.name)]);
    return query.get();
  }

  /// Search for artist by name
  Future<List<Artist>> search(String name) {
    final query = select(artists);
    query.where((tbl) => tbl.name.like('%$name%'));
    return query.get();
  }

  /// Returns a list of artist ids which are similar to the given artist id.
  Future<List<int>> similarIds(int id) async {
    final query = select(artists)..where((tbl) => tbl.id.equals(id));
    return (await query.getSingle()).similar?.toList();
  }

  /// Returns a list of song ids that are the top songs of the given artist (from their id).
  Future<List<int>> topSongs(int id) async {
    final query = select(artists)..where((tbl) => tbl.id.equals(id));
    return (await query.getSingle()).topSongs?.toList();
  }

  /// Returns an artist by their id.
  Future<Artist> byId(int id) {
    final query = select(artists);
    query.where((tbl) => tbl.id.equals(id));
    return query.getSingle();
  }

  /// Returns a list of artists given a list of corresponding ids.
  Future<List<Artist>> byIdList(List<int> idList) {
    final query = select(artists);
    query.where((tbl) => tbl.id.isIn(idList));
    return query.get();
  }

  /// ========== DATABASE MANAGEMENT ==========

  /// Deletes the current library.
  Future<void> clear() => delete(artists).go();

  /// Inserts a list of xml elements into the database.
  Future<void> insertElements(List<XmlElement> elements) {
    return batch((batch) {
      final companions = elements.map((e) => _elementToCompanion(e)).toList();
      batch.insertAll(artists, companions);
    });
  }

  /// Updates an artist id with a list of ids similar to them.
  Future<void> updateSimilar(int id, List<int> similarIds) async {
    final query = update(artists);
    query.where((tbl) => tbl.id.equals(id));
    query.write(
      ArtistsCompanion(similar: Value(Uint8List.fromList(similarIds))),
    );
  }

  /// Converts an xml element to a companion.
  ArtistsCompanion _elementToCompanion(XmlElement element) {
    return ArtistsCompanion.insert(
      id: Value(int.parse(element.getAttribute('id'))),
      name: element.getAttribute('name'),
      albumCount: int.parse(element.getAttribute('albumCount')),
      art: Value(element.getAttribute('coverArt')),
    );
  }
}
