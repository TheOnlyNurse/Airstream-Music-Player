import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:moor/moor.dart';
import 'package:xml/xml.dart';

import '../extensions/functional_lists.dart';
import '../global_assets.dart';
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

  /// Requests a random list of albums.
  ///
  /// Since the album order should also be random, a subsequent shuffle is needed.
  Future<Either<String, List<Album>>> random() async {
    return (await _database.random(50))
        .removeEmpty(_Error.albumsEmpty)
        .map((albums) => albums.fShuffle);
  }

  /// Returns the most recently added albums.
  Future<Either<String, List<Album>>> recentlyAdded() async {
    return (await _database.recentlyAdded()).removeEmpty(_Error.albumsEmpty);
  }

  /// Returns the most played albums according to the server.
  Future<Either<String, List<Album>>> mostPlayed() async {
    return _fromCache('frequent');
  }

  /// Returns the recently played albums according to the server.
  Future<Either<String, List<Album>>> recentlyPlayed() async {
    return _fromCache('recent');
  }

  /// Returns a list of genres available within albums.
  Future<Either<String, List<String>>> allGenres() async {
    return (await _database.extractGenres())
        .removeEmpty('No genres found in database.')
        .map((r) => r.removeDuplicates);
  }

  /// Returns a list of decades dictated by album years.
  Future<Either<String, List<int>>> decades() async {
    return (await _database.extractDecades())
        .removeEmpty('No decades found in database.')
        .map((r) => r.removeDuplicates);
  }

  /// Returns albums ordered by alphabet.
  Future<Either<String, List<Album>>> byAlphabet() async {
    return (await _database.byAlphabet()).removeEmpty(_Error.albumsEmpty);
  }

  /// Returns albums that match a given artist id.
  Future<Either<String, List<Album>>> fromArtist(Artist artist) async {
    return (await _database.byArtistId(artist.id))
        .removeEmpty(_Error.albumsEmpty);
  }

  /// Returns albums that are marked as starred, updating if an empty list is returned.
  Future<Either<String, List<Album>>> starred() async {
    return (await _database.starred()).removeEmpty(_Error.albumsEmpty);
  }

  /// Returns an album by it's id.
  Future<Either<String, Album>> byId(int id) async {
    final album = await _database.byId(id);
    return album == null ? left(_Error.noAlbum) : right(album);
  }

  /// Returns an album list that matches a genre.
  Future<Either<String, List<Album>>> genre(String genre) async {
    return (await _database.byGenre(genre)).removeEmpty(_Error.albumsEmpty);
  }

  /// Returns an album list with years within the given decade.
  Future<Either<String, List<Album>>> decade(int decade) async {
    return (await _database.byDecade(decade)).removeEmpty(_Error.albumsEmpty);
  }

  /// Returns a list of albums whose title matches a given request.
  Future<Either<String, List<Album>>> search(String request) async {
    return (await _database.search(request)).removeEmpty(_Error.albumsEmpty);
  }

  /// ========== DB MANAGEMENT ==========

  /// Replaces starred [Album] objects with those marked as starred on the server.
  Future<void> syncStarred() async {
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
  Future<void> syncLibrary() async {
    final accumulator = <XmlElement>[];

    while (true) {
      final elements = (await _server.albumList(
        type: 'alphabeticalByName',
        specifics: 'size=500&offset=${accumulator.length}',
      ))
          .fold<List<XmlElement>>((error) => [], (response) => response);
      if (elements.isEmpty) break;
      accumulator.addAll(elements);
    }

    // Only delete database after new elements have been downloaded
    if (accumulator.isNotEmpty) {
      await _database.clear();
      await _database.insertElements(accumulator);
    }
  }

  Future<void> syncRecentlyPlayed() => _syncCacheList('recent');

  Future<void> syncMostPlayed() => _syncCacheList('frequent');

  /// Returns albums from a temporary cache, typically used for most/recently played.
  ///
  /// Album ids are stored in the cache and are converted to album objects.
  Future<Either<String, List<Album>>> _fromCache(String type) async {
    final cache = Hive.box('cache');
    final idList = cache.get('${type}Albums') as List<int>;
    if (idList == null) return left(_Error.noCached);

    return (await _database.byIdList(idList))
        .removeEmpty('No $type found in database.')
        .map((r) => r.matchSort<int>(idList, (id, album) => id == album.id));
  }

  Future<void> _syncCacheList(String type) async {
    int extractId(XmlElement e) => int.parse(e.getAttribute('id'));

    final ids = (await _server.albumList(type: type, specifics: 'size=50'))
        .map((elements) => elements.map(extractId).toList())
        .flatMap((list) => list.removeEmpty('No albums found.'))
        .fold((l) => [], (ids) => ids);

    if (ids.isNotEmpty) Hive.box('cache').put('${type}Albums', ids);
  }
}

class _Error {
  // This class is not meant to be instantiated or extended.
  _Error._();

  static const noAlbum = 'Album not found.';

  static const albumsEmpty =
      'No albums found in database. Try syncing with the server.';

  static const noCached = 'Cached album list needs to be updated.';
}
