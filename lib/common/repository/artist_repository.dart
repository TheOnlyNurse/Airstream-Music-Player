import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:xml/xml.dart';

import '../../global_assets.dart';
import '../extensions/functional_lists.dart';
import '../providers/artists_dao.dart';
import '../providers/moor_database.dart';
import '../repository/server_repository.dart';

class ArtistRepository {
  ArtistRepository({ArtistsDao artistsDao, ServerRepository server})
      : _server = getIt<ServerRepository>(server),
        _database = artistsDao ?? ArtistsDao(GetIt.I.get<MoorDatabase>());

  final ArtistsDao _database;
  final ServerRepository _server;

  Future<Either<String, List<Artist>>> byAlphabet() async {
    return (await _database.byAlphabet()).removeEmpty(_Error.artistsEmpty);
  }

  Future<Either<String, List<Artist>>> search(String name) async {
    return (await _database.search(name)).removeEmpty(_Error.artistsEmpty);
  }

  /// Clears the local database in favour for one from the server.
  Future<void> sync() async {
    return (await _server.artistList()).fold(
      (error) => throw UnimplementedError(error),
      (elements) async {
        await _database.clear();
        await _database.insertElements(elements);
      },
    );
  }

  /// Returns an artist by their id.
  Future<Either<String, Artist>> byId(int id) async {
    final artist = await _database.byId(id);
    return artist == null ? left(_Error.noArtist) : right(artist);
  }

  /// Returns a list of artists similar to the artist given.
  ///
  /// Fetches information from the server only if the information is missing.
  Future<Either<String, List<Artist>>> similar(Artist artist) async {
    int extractId(XmlElement e) => int.parse(e.getAttribute('id'));

    var cachedIds = await _database.similarIds(artist.id);
    if (cachedIds == null) {
      cachedIds = (await _server.similarArtists(artist.id)).fold<List<int>>(
        (error) => [],
        (elements) => elements.map(extractId).toList(),
      );
      await _database.updateSimilar(artist.id, cachedIds);
    }

    return (await _database.byIdList(cachedIds))
        .removeEmpty(_Error.artistsEmpty);
  }
}

class _Error {
  // This class is not meant to be instantiated or extended.
  _Error._();

  static const artistsEmpty = 'Failed to find any artists in database.';

  static const noArtist = 'Failed to find artist.';
}
