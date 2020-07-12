import 'dart:collection';
import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/response/album_response.dart';
import 'package:airstream/models/response/server_response.dart';
import 'package:moor/moor.dart';
import 'package:xml/xml.dart' as xml;

part 'albums_dao.g.dart';

class Albums extends Table {
  IntColumn get id => integer()();

  TextColumn get title => text()();

  TextColumn get artist => text()();

  IntColumn get artistId => integer()();

  IntColumn get songCount => integer()();

  TextColumn get art => text()();

  DateTimeColumn get created => dateTime()();

  TextColumn get genre => text().nullable()();

  IntColumn get year => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseDao(tables: [Albums])
class AlbumsDao extends DatabaseAccessor<MoorDatabase> with _$AlbumsDaoMixin {
  /// So that the main database can create an instance of this dao
  AlbumsDao(MoorDatabase db) : super(db);

  /// Get a specific type of album list
  /// An additional argument maybe required depending on the request
  Future<AlbumResponse> library(AlbumLibrary type, {dynamic argument}) async {
    // If the database is empty, download, passing on any errors
    if (await _dbIsEmpty()) {
      final response = await _download();
      if (response.hasNoData) return response;
    }

    Future<List<Album>> futureAlbums;
    switch (type) {
      case AlbumLibrary.random:
        futureAlbums = _random();
        break;
      case AlbumLibrary.newlyAdded:
        futureAlbums = _newlyAdded();
        break;
      case AlbumLibrary.recent:
        futureAlbums = _playedOfType('recent');
        break;
      case AlbumLibrary.frequent:
				futureAlbums = _playedOfType('frequent');
				break;
      case AlbumLibrary.byAlphabet:
				futureAlbums = _byAlphabet();
				break;
      case AlbumLibrary.byGenre:
				futureAlbums = _byGenre(argument);
				break;
      case AlbumLibrary.byDecade:
				futureAlbums = _byDecade(argument);
				break;
			case AlbumLibrary.search:
				futureAlbums = _search(argument);
				break;
			case AlbumLibrary.byArtist:
				futureAlbums = _byArtist(argument);
				break;
			default:
				throw UnimplementedError('$type');
		}

		final returnAlbums = await futureAlbums;
		if (returnAlbums == null || returnAlbums.isEmpty) {
			return AlbumResponse(error: 'Failed to find any albums.');
		} else {
			return _checkIfOnline(AlbumResponse(
				hasData: true,
				albums: returnAlbums,
			));
		}
  }

  /// Deletes the entire library in favour of downloading a new database
  Future<AlbumResponse> updateLibrary() async {
    await delete(albums).go();
    return _download();
  }

  /// Returns an album by its unique id
  Future<AlbumResponse> byId(int id) async {
    final query = select(albums);
    query.where((a) => a.id.equals(id));
    final album = await query.getSingle();
    if (album == null) {
      return AlbumResponse(error: 'Failed to find id: $id.');
    } else {
      return _checkIfOnline(AlbumResponse(hasData: true, albums: [album]));
    }
  }

  /// Returns albums that are starred by querying ids from the starred provider
  /// Updates this library if return album length is not equal to the id list length
  /// provided by the starred provider
  Future<AlbumResponse> starred() async {
    final response = await Repository().starred.query('album');
    if (response.hasNoData) return AlbumResponse(passOn: response);
    List<Album> albums = await _byIdList(response.idList);
    // Make sure empty album lists aren't passed through
    if (albums.length != response.idList.length) {
      if (Repository().settings.isOnline) {
        final serverResponse = await _download();
        // If new data has been parsed, then try to update return list
        if (serverResponse.hasData) albums = await _byIdList(response.idList);
      }
      // If albums is empty (despite the update above) only then return error
      if (albums.isEmpty) {
        return AlbumResponse(error: 'Failed to find starred album ids.');
      }
    }

    return _checkIfOnline(AlbumResponse(hasData: true, albums: albums));
  }

  /// Returns a list of genres as a list of string
  Future<AlbumResponse> genres() async {
    final query = select(albums);
    query.where((a) => isNotNull(a.genre));
    query.orderBy([(a) => OrderingTerm(expression: a.genre)]);
    final genres = (await query.get()).map((e) => e.genre);
    final condensed = LinkedHashSet<String>.from(genres);
    if (condensed.isEmpty) {
      return AlbumResponse(error: 'Failed to find any albums with genres.');
    } else {
      return AlbumResponse(hasData: true, genres: condensed.toList());
    }
  }

  /// Returns a list of decades as an int list
  Future<AlbumResponse> decades() async {
    final query = select(albums);
    query.where((a) => isNotNull(a.year));
    // Order by descending year
    query.orderBy([
      (a) {
        return OrderingTerm(expression: a.year, mode: OrderingMode.desc);
      }
    ]);
		// Round year down to decade
		final decades = (await query.get()).map((e) => e.year ~/ 10 * 10);
		final condensed = LinkedHashSet<int>.from(decades);
		if (condensed.isEmpty) {
			return AlbumResponse(error: 'Failed to find any albums with years.');
		} else {
			return AlbumResponse(hasData: true, decades: condensed.toList());
		}
	}

	/// Returns an album list given a list of album ids
	Future<List<Album>> _byIdList(List<int> idList) async {
		final albums = <Album>[];
		for (var id in idList) {
			final response = await byId(id);
			if (response.hasData) albums.add(response.album);
		}
		return albums;
	}

	/// Returns albums based on artistId
	Future<List<Album>> _byArtist(int artistId) async {
		final query = select(albums);
		query.where((tbl) => tbl.artistId.equals(artistId));
		return query.get();
	}

	/// Get an album based on a title request
	Future<List<Album>> _search(String request) async {
		final query = select(albums);
		query.where((a) => a.title.like('%$request%'));
		return query.get();
  }

  /// Gets an album played type (frequent or recent) as dictated by the server
  /// If there is no connection, returns the last available album list
  Future<List<Album>> _playedOfType(String type) async {
    assert(type == 'recent' || type == 'frequent');
    final hiveBox = Hive.box('albums');
    var idList = await _fetchIdList(type);
    // If there are no new values, get the last saved values, else save the new
    // values
    if (idList == null) {
      idList = hiveBox.get(type);
    } else {
      hiveBox.put(type, idList);
    }
    // If there are no saved values
    if (idList == null) return null;
    // Get the albums from db
    return _queryIdList(idList);
  }

  /// Album list from multiple ids
  Future<List<Album>> _queryIdList(List<int> idList) async {
    final albumList = <Album>[];
    for (var id in idList) {
      final album = await _queryId(id);
      if (album != null) albumList.add(album);
    }
    return albumList;
  }

  /// Album from a single id
  Future<Album> _queryId(int id) async {
    final query = select(albums);
    query.where((a) => a.id.equals(id));
    return query.getSingle();
  }

  Future<List<int>> _fetchIdList(String type) async {
    final response = await _fetch(type: type, add: 'size=50');
    if (response.hasNoData) return null;
    final elements = documentToElements(response.document);
    if (elements.isEmpty) return null;
    return elements.map((e) => int.parse(e.getAttribute('id'))).toList();
  }

  /// Get albums by years that between a given decade and the next
  Future<List<Album>> _byDecade(int decade) async {
    // Make sure decade is a multiple of 10
    assert(decade.gcd(10) == 10);
    final query = select(albums);
    query.where((a) => a.year.isBetweenValues(decade - 1, decade + 10));
    return query.get();
  }

  /// Get albums that match a particular genre
  Future<List<Album>> _byGenre(String genre) async {
    final query = select(albums);
    query.where((tbl) => tbl.genre.equals(genre));
    return query.get();
  }

  /// Albums by alphabet
  Future<List<Album>> _byAlphabet() async {
    final query = select(albums);
    query.orderBy([(a) => OrderingTerm(expression: a.title)]);
    return query.get();
  }

  /// Randomised list of albums
  Future<List<Album>> _random() async {
    // TODO: find a in SQL way to randomise the list
    final list = await select(albums).get();
    list.shuffle();
    return list;
  }

  /// Albums ordered by date of addition
  Future<List<Album>> _newlyAdded() async {
    final query = select(albums);
    query.orderBy([(t) => OrderingTerm(expression: t.created)]);
    return query.get();
  }

  /// Downloads all albums from the server
  Future<AlbumResponse> _download() async {
    int offset = 0;
    while (true) {
      final response = await _fetch(
        type: 'alphabeticalByName',
        add: 'size=500&offset=$offset',
      );
      if (response.hasNoData) return AlbumResponse(passOn: response);
      final elements = documentToElements(response.document);
      if (elements.isEmpty) break;
      await _insertElements(elements);
      offset += 500;
    }
    if (await _dbIsEmpty()) {
      return AlbumResponse(error: 'No albums found on server');
    } else {
      return AlbumResponse(hasData: true);
    }
  }

  /// Fetch information from the server
  Future<ServerResponse> _fetch({@required String type, String add}) {
    assert(type != null);
    return ServerProvider().fetchXml('getAlbumList2?type=$type&$add');
  }

  /// Converts an element list into companions and inserts into the db
  Future<Null> _insertElements(List<xml.XmlElement> elements) async {
    await batch((batch) {
      final companions = <AlbumsCompanion>[];
      for (var element in elements) {
        companions.add(_elementToCompanion(element));
      }
      batch.insertAll(albums, companions);
    });
    return;
  }

  /// Assigns xml attributes to corresponding Album attributes
  AlbumsCompanion _elementToCompanion(xml.XmlElement element) {
    return AlbumsCompanion.insert(
      id: Value(int.parse(element.getAttribute('id'))),
      title: element.getAttribute('name'),
      artist: element.getAttribute('artist'),
      artistId: int.parse(element.getAttribute('artistId')),
      songCount: int.parse(element.getAttribute('songCount')),
      art: element.getAttribute('coverArt'),
      created: DateTime.parse(element.getAttribute('created')),
      genre: Value(element.getAttribute('genre')),
      year: Value(_parseAsInt(element.getAttribute('year'))),
    );
  }

  /// Either parses a string or returns null if the object is null
  int _parseAsInt(String attribute) {
    return attribute == null ? null : int.parse(attribute);
  }

  /// Return cached albums only if in offline mode
  Future<AlbumResponse> _checkIfOnline(AlbumResponse input) async {
    if (Repository().settings.isOffline) {
      final cachedList = <Album>[];
      final response = await Repository().audioCache.cachedAlbums();
      if (response.hasNoData) return AlbumResponse(passOn: response);
      // Iterate through cache and add albums
      for (var album in input.albums) {
        if (response.idList.contains(album.id)) cachedList.add(album);
      }
      // Return error instead of empty list
      if (cachedList.isEmpty) {
        return AlbumResponse(error: 'No cached albums found.');
      } else {
        return AlbumResponse(hasData: true, albums: cachedList);
      }
    } else {
      return input;
    }
  }

  /// Returns all album elements in xml document
  List<xml.XmlElement> documentToElements(xml.XmlDocument document) {
    return document.findAllElements('album').toList();
  }

  /// Check if database is empty
  Future<bool> _dbIsEmpty() async {
    final query = select(albums);
    query.limit(1);
    return (await query.getSingle()) == null;
  }

}
