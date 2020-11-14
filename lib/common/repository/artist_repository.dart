import 'package:get_it/get_it.dart';

import '../global_assets.dart';
import '../models/repository_response.dart';
import '../providers/artists_dao.dart';
import '../providers/moor_database.dart';
import '../repository/server_repository.dart';

class ArtistRepository {
  ArtistRepository({ArtistsDao artistsDao, ServerRepository server})
      : _server = getIt<ServerRepository>(server),
        _database = artistsDao ?? ArtistsDao(GetIt.I.get<MoorDatabase>());

  final ArtistsDao _database;
  final ServerRepository _server;

  Future<ListResponse<Artist>> byAlphabet() async {
    final artists = await _database.byAlphabet();
    return _removeEmptyLists(artists);
  }

  Future<ListResponse<Artist>> search(String name) async {
    final artists = await _database.search(name);
    if (artists.isEmpty) {
      return const ListResponse<Artist>(error: 'Nothing found.');
    } else {
      return ListResponse<Artist>(data: artists);
    }
  }

  /// Clears the local database in favour for one from the server.
  Future<void> forceSync() async {
    return (await _server.artistList()).fold(
      (error) => throw UnimplementedError(error),
      (elements) async {
        await _database.clear();
        await _database.insertElements(elements);
      },
    );
  }

  /// Returns an artist by their id.
  Future<SingleResponse<Artist>> byId(int id) async {
    final artist = await _database.byId(id);
    if (artist == null) {
      return const SingleResponse<Artist>(
        error: 'Failed to find artist.',
        solutions: [ErrorSolutions.database],
      );
    } else {
      return SingleResponse<Artist>(data: artist);
    }
  }

  /// Returns a list of artists similar to the artist given.
  ///
  /// Fetches information from the server only if the information is missing.
  Future<ListResponse<Artist>> similar(Artist artist) async {
    var cachedIds = await _database.similarIds(artist.id);
    if (cachedIds == null) {
      cachedIds = (await _server.similarArtists(artist.id)).fold(
        (error) => [],
        (elements) =>
            elements.map((e) => int.parse(e.getAttribute('id'))).toList(),
      );

      await _database.updateSimilar(artist.id, cachedIds);
    }
    return _removeEmptyLists(await _database.byIdList(cachedIds));
  }
}

ListResponse<Artist> _removeEmptyLists(List<Artist> artists) {
  if (artists.isEmpty) {
    return const ListResponse<Artist>(
      error: 'No artists found within database.',
      solutions: [ErrorSolutions.database, ErrorSolutions.network],
    );
  } else {
    return ListResponse<Artist>(data: artists);
  }
}
