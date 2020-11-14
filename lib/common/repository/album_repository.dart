import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../global_assets.dart';
import '../models/repository_response.dart';
import '../providers/albums_dao.dart';
import '../providers/moor_database.dart';
import 'scheduler.dart';
import 'server_repository.dart';

class AlbumRepository {
  AlbumRepository({
    AlbumsDao albumsDao,
    ServerRepository server,
    Scheduler scheduler,
  })  : _database = albumsDao ?? AlbumsDao(GetIt.I.get<MoorDatabase>()),
        _server = getIt<ServerRepository>(server),
        _scheduler = getIt<Scheduler>(scheduler);

  final AlbumsDao _database;
  final ServerRepository _server;
  final Scheduler _scheduler;

  /// ========== ALBUM COLLECTIONS ==========

  /// Requests a random list of albums.
  ///
  /// Since the album order should also be random, a subsequent shuffle is needed.
  Future<ListResponse<Album>> random() async {
    final albums = await _database.random(50);
    albums.shuffle();
    return _removeEmptyLists(albums);
  }

  /// Returns the most recently added albums
  Future<ListResponse<Album>> recentlyAdded() async {
    final albums = await _database.recentlyAdded();
    return _removeEmptyLists(albums);
  }

  /// Returns the most played albums according to the server.
  Future<ListResponse<Album>> mostPlayed({bool forceFetch = false}) async {
    final albums = await _albumsFromCache(
      cacheKey: 'mostPlayedAlbums',
      type: 'frequent',
      forceFetch: forceFetch,
    );
    return _removeEmptyLists(albums);
  }

  /// Returns the recently played albums according to the server.
  Future<ListResponse<Album>> recentlyPlayed({bool forceFetch = false}) async {
    final albums = await _albumsFromCache(
      cacheKey: 'recentlyPlayedAlbums',
      type: 'recent',
      forceFetch: forceFetch,
    );
    return _removeEmptyLists(albums);
  }

  /// Returns a list of genres available within albums.
  Future<ListResponse<String>> allGenres() async {
    final genres = await _database.extractGenres();
    if (genres.isEmpty) {
      return _errorResponse<String>('No genres found within albums.');
    } else {
      // Made into a set and then back into a list to remove duplicate genres
      final withoutDuplicates = genres.toSet().toList();
      return ListResponse<String>(data: withoutDuplicates);
    }
  }

  /// Returns a list of decades dictated by album years.
  Future<ListResponse<int>> decades() async {
    final decades = await _database.extractDecades();
    if (decades.isEmpty) {
      return _errorResponse('No decades found within albums.');
    } else {
      final withoutDuplicates = decades.toSet().toList();
      return ListResponse<int>(data: withoutDuplicates);
    }
  }

  /// Returns albums ordered by alphabet.
  Future<ListResponse<Album>> byAlphabet() async {
    final albums = await _database.byAlphabet();
    return _removeEmptyLists(albums);
  }

  /// ========== UNIQUE ALBUM ARRANGEMENTS ==========

  /// Returns albums that match a given artist id.
  Future<ListResponse<Album>> fromArtist(Artist artist) async {
    return _removeEmptyLists(await _database.byArtistId(artist.id));
  }

  /// Returns albums that are marked as starred, updating if an empty list is returned.
  Future<ListResponse<Album>> starred() async {
    List<Album> albums = await _database.starred();
    if (albums.isEmpty) {
      await forceSyncStarred();
      albums = await _database.starred();
    }
    return _removeEmptyLists(albums);
  }

  /// Returns an album by it's id.
  Future<SingleResponse<Album>> byId(int id) async {
    final album = await _database.byId(id);
    if (album == null) {
      return const SingleResponse<Album>(
        error: 'Failed to find album.',
        solutions: [ErrorSolutions.database],
      );
    } else {
      return SingleResponse<Album>(data: album);
    }
  }

  /// Returns an album list that matches a genre.
  Future<ListResponse<Album>> genre(String genre) async {
    return _removeEmptyLists(await _database.byGenre(genre));
  }

  /// Returns an album list with years within the given decade.
  Future<ListResponse<Album>> decade(int decade) async {
    return _removeEmptyLists(await _database.byDecade(decade));
  }

  /// Returns a list of albums whose title matches a given request.
  Future<ListResponse<Album>> search(String request) async {
    final results = await _database.search(request);
    if (results.isEmpty) {
      return const ListResponse<Album>(error: 'Nothing found.');
    } else {
      return ListResponse<Album>(data: results);
    }
  }

  /// ========== DB MANAGEMENT ==========

  /// Replaces starred [Album] objects with those marked as starred on the server.
  Future<void> forceSyncStarred() async {
    return (await _server.starred('album')).fold(
      (error) => throw Exception('Unimplemented error message: $error'),
      (elements) async {
        final ids = elements.map((e) => int.parse(e.getAttribute('id')));
        await _database.clearStarred();
        await _database.markStarred(ids.toList());
      },
    );
  }

  Future<void> updateStarred(Album album, {@required bool starred}) async {
    await _database.markStarred([album.id], starred: starred);
    final request = starred ? 'star' : 'unstar';
    _scheduler.schedule('$request?albumId=${album.id}');
  }

  /// Overrides the local database with one from the server.
  Future<void> forceSync() async {
    final allElements = <XmlElement>[];
    int offset = 0;

    while (true) {
      final elements = (await _server.albumList(
        type: 'alphabeticalByName',
        specifics: 'size=500&offset=$offset',
      ))
          .fold<List<XmlElement>>((error) => [], (response) => response);
      if (elements.isEmpty) break;
      allElements.addAll(elements);
      offset += 500;
    }

    // Only delete database after new elements have been downloaded
    if (allElements.isNotEmpty) {
      await _database.clear();
      await _database.insertElements(allElements);
    }
  }

  /// ========== COMMON FUNCTIONS ==========

  /// Returns a ListResponse object with filled in solutions.
  ListResponse<E> _errorResponse<E>(String error) {
    return ListResponse<E>(
      error: error,
      solutions: [ErrorSolutions.database, ErrorSolutions.network],
    );
  }

  /// Returns an error string and solutions instead of empty lists.
  ListResponse<Album> _removeEmptyLists(List<Album> albums) {
    final _noAlbumsFound = _errorResponse<Album>(
      'No albums found within database.',
    );
    return albums.isEmpty ? _noAlbumsFound : ListResponse<Album>(data: albums);
  }

  /// Returns albums from a temporary cache, typically used for most/recently played.
  ///
  /// Album ids are stored in the cache and are converted to album objects.
  /// Does not return null objects, only empty lists.
  Future<List<Album>> _albumsFromCache({
    @required String cacheKey,
    @required String type,
    @required bool forceFetch,
  }) async {
    assert(cacheKey != null);
    assert(type != null);
    assert(forceFetch != null);

    final cache = Hive.box('cache');
    var idList = cache.get(cacheKey) as List<int>;

    if (idList == null || forceFetch) {
      final idsFromServer = await _idsFromType(type);
      idList = idsFromServer;
      cache.put(cacheKey, idList);
    }

    final unsorted = await _database.byIdList(idList);
    // Ids from database and server can be out of sync.
    if (unsorted.isEmpty) {
      return [];
    } else {
      // Reordering to match albums with it's appearance in the cached id list.
      return idList
          .map((id) => unsorted.firstWhere((album) => album.id == id))
          .toList();
    }
  }

  /// Returns a list of ids given an album fetch type
  Future<List<int>> _idsFromType(String type) async {
    return (await _server.albumList(type: type, specifics: 'size=50')).fold(
      (error) => throw UnimplementedError(error),
      (r) {
        int idFromElement(e) => int.parse(e.getAttribute('id') as String);
        return r.isEmpty ? [] : r.map(idFromElement).toList();
      },
    );
  }
}
