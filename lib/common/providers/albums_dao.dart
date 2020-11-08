/// External Packages
import 'package:moor/moor.dart';
import 'package:xml/xml.dart';

/// Internal Links
import 'moor_database.dart';
import 'repository/repository.dart';

part 'albums_dao.g.dart';

class Albums extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get artist => text()();

  IntColumn get artistId => integer()();

  IntColumn get songCount => integer()();

  TextColumn get art => text().nullable()();

  DateTimeColumn get created => dateTime()();

  TextColumn get genre => text().nullable()();

  IntColumn get year => integer().nullable()();

  BoolColumn get isCached => boolean().withDefault(const Constant(false))();

  BoolColumn get isStarred => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [Albums])
class AlbumsDao extends DatabaseAccessor<MoorDatabase> with _$AlbumsDaoMixin {
  AlbumsDao(MoorDatabase db) : super(db);

  /// Returns an expression that returns cached albums if offline.
  Expression<bool> _cacheChecker($AlbumsTable tbl, Expression<bool> addWhere) {
    if (Repository().settings.isOffline) {
      return tbl.isCached.equals(true) & addWhere;
    } else {
      return addWhere;
    }
  }

  /// ========== DB QUERIES ==========

  /// Returns albums ordered by alphabet.
  Future<List<Album>> byAlphabet() async {
    final query = select(albums);
    query.orderBy([(a) => OrderingTerm(expression: a.title)]);
    return query.get();
  }

  /// Returns a number of random albums.
  ///
  /// SELECT * FROM table WHERE random() % k = 0 LIMIT n.
  /// k is an integer constant that determines how probable it is to select a given row.
  /// For instance, a k of 2 means (about) 50% probability of selecting a row,
  /// k of 3 means 33%, k of 4 means 25% and so on.
  /// http://blog.rodolfocarvalho.net/2012/05/how-to-select-random-rows-from-sqlite.html
  Future<List<Album>> random(int length) async {
    // k of 8 means 12.5% chance of selecting a row
    const randomWhere = 'WHERE random() % 8 = 0';
    const cached = ' AND is_cached = 1';
    final queryWhere =
        Repository().settings.isOffline ? randomWhere + cached : randomWhere;
    final selectQuery = 'SELECT * FROM albums $queryWhere LIMIT $length';
    final query = await customSelect(selectQuery).get();
    return query.map((e) => Album.fromData(e.data, db)).toList();
  }

  /// Returns albums that are marked as starred.
  Future<List<Album>> starred() async {
    final query = select(albums);
    query.where((a) => a.isStarred.equals(true));
    return query.get();
  }

  /// Returns all the genres recorded within albums.
  Future<List<String>> extractGenres() async {
    final query = select(albums);
    query.where((a) => _cacheChecker(a, isNotNull(a.genre)));
    query.orderBy([(a) => OrderingTerm(expression: a.genre)]);
    return query.map((row) => row.genre).get();
  }

  /// Returns a list of decades as an int list
  Future<List<int>> extractDecades() async {
    final query = select(albums);
    query.where((a) => isNotNull(a.year));
    // Order by descending year
    query.orderBy([(a) => OrderingTerm.desc(a.year)]);
    // Round year down to decade
    return query.map((e) => e.year ~/ 10 * 10).get();
  }

  /// Returns an album list given a list of album ids.
  ///
  /// Note that the list will be ordered by its row index and not the given list.
  Future<List<Album>> byIdList(List<int> idList) async {
    final query = select(albums)..where((tbl) => tbl.id.isIn(idList));
    return query.get();
  }

  /// Get an album based on a title request
  Future<List<Album>> search(String request) async {
    final query = select(albums);
    query.where((a) => a.title.like('%$request%'));
    return query.get();
  }

  /// Returns albums that are in given decade by title.
  Future<List<Album>> byDecade(int decade) async {
    assert(decade.gcd(10) == 10); // Make sure decade is a multiple of 10
    final query = select(albums);
    query.where((a) => a.year.isBetweenValues(decade - 1, decade + 10));
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.get();
  }

  /// Return albums that match a particular genre.
  Future<List<Album>> byGenre(String genre) async {
    final query = select(albums);
    query.where((tbl) => tbl.genre.equals(genre));
    query.orderBy([(t) => OrderingTerm(expression: t.title)]);
    return query.get();
  }

  /// Albums ordered by date they were added to the server.
  Future<List<Album>> recentlyAdded() {
    final query = select(albums);
    query.orderBy([(t) => OrderingTerm.desc(t.created)]);
    query.limit(50);
    return query.get();
  }

  /// Albums that match a given artist id.
  Future<List<Album>> byArtistId(int id) {
    final query = select(albums);
    query.where((a) => a.artistId.equals(id));
    return query.get();
  }

  Future<Album> byId(int id) {
    return (select(albums)..where((a) => a.id.equals(id))).getSingle();
  }

  /// ========== DB MANAGEMENT ==========

  Future<void> clear() => delete(albums).go();

  /// Converts an element list into companions and inserts into the db
  Future<void> insertElements(List<XmlElement> elements) async {
    return batch((batch) {
      final companions = elements.map((e) => _elementToCompanion(e)).toList();
      batch.insertAll(albums, companions);
    });
  }

  /// Updates albums that match a given id list to be starred.
  Future<void> markStarred(List<int> idList, {bool starred = true}) async {
    return batch((batch) {
      batch.update(
        albums,
        AlbumsCompanion(isStarred: Value(starred)),
        where: ($AlbumsTable tbl) => tbl.id.isIn(idList),
      );
    });
  }

  /// Removes all albums marked as starred.
  Future<void> clearStarred() async {
    return batch((batch) {
      batch.update(
        albums,
        const AlbumsCompanion(isStarred: Value(false)),
        where: ($AlbumsTable tbl) => tbl.isStarred.equals(true),
      );
    });
  }

  /// Assigns xml attributes to corresponding Album attributes
  AlbumsCompanion _elementToCompanion(XmlElement element) {
    return AlbumsCompanion.insert(
      id: Value(int.parse(element.getAttribute('id'))),
      title: element.getAttribute('name'),
      artist: element.getAttribute('artist'),
      artistId: int.parse(element.getAttribute('artistId')),
      songCount: int.parse(element.getAttribute('songCount')),
      art: Value(element.getAttribute('coverArt')),
      created: DateTime.parse(element.getAttribute('created')),
      genre: Value(element.getAttribute('genre')),
      year: Value(_parseAsInt(element.getAttribute('year'))),
    );
  }

  /// Either parses a string or passes on null.
  int _parseAsInt(String attribute) {
    return attribute == null ? null : int.parse(attribute);
  }
}
