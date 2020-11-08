import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../models/repository_response.dart';
import '../providers/artists_dao.dart';
import '../providers/moor_database.dart';
import '../providers/server_provider.dart';
import '../static_assets.dart';

class ArtistRepository {
  final ArtistsDao _database;

  const ArtistRepository({@required ArtistsDao artistsDao})
      : assert(artistsDao != null),
        _database = artistsDao;

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
    final response = await ServerProvider().fetchXml('getArtists?');
    if (response.hasError) throw UnimplementedError();
    await _database.clear();
    final elements = response.data.findAllElements('artist').toList();
    return _database.insertElements(elements);
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
      final response = await ServerProvider().fetchXml(
        'getArtistInfo2?id=${artist.id}&count=10',
      );

      if (response.hasData) {
        final elements = response.data.findAllElements('similarArtist');
        cachedIds = elements.map((e) {
          return int.parse(e.getAttribute('id'));
        }).toList();
      } else {
        cachedIds = [];
      }

      await _database.updateSimilar(artist.id, cachedIds);
    }
    return _removeEmptyLists(await _database.byIdList(cachedIds));
  }

  /// ========== COMMON FUNCTIONS ==========

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
}
