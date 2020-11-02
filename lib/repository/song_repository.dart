import 'package:flutter/foundation.dart';

/// Internal
import '../models/playlist_model.dart';
import '../models/repository_response.dart';
import '../providers/moor_database.dart';
import '../providers/songs_dao.dart';

class SongRepository {
  SongRepository({@required SongsDao songsDao})
      : assert(songsDao != null),
        _database = songsDao;

  final SongsDao _database;

  /// Returns a song list (with on item) by id
  Future<ListResponse<Song>> byId(int id) {
    return _database.search(SongSearch.byId, argument: id);
  }

  /// Get songs in a given album
  Future<ListResponse<Song>> fromAlbum(Album album) {
    return _database.search(SongSearch.byAlbum, argument: album.id);
  }

  /// Convert playlist song id list to song details from database
  Future<ListResponse<Song>> fromPlaylist(Playlist playlist) async {
    final songList = <Song>[];
    String lastError;

    for (int id in playlist.songIds) {
      final query = await _database.search(SongSearch.byId, argument: id);
      if (query.hasError) {
        lastError = query.error;
        continue;
      }
      songList.add(query.data.first);
    }

    if (songList.isNotEmpty) {
      return ListResponse<Song>(data: songList);
    } else if (lastError != null) {
      throw UnimplementedError();
    } else {
      return ListResponse<Song>(error: 'No songs found in playlist');
    }
  }

  Future<ListResponse<Song>> starred() => _database.starred();

  Future<ListResponse<Song>> topSongsOf(Artist artist) =>
      _database.topSongsOf(artist);

  /// Searches both song titles and artist names
  /// Searches artist names
  ///  1. When searching song titles returns less than 5 results
  ///  2. When song titles returns no results
  Future<ListResponse<Song>> search({String query}) async {
    final titleQuery =
        await _database.search(SongSearch.byTitle, argument: query);
    if (titleQuery.hasData) {
      if (titleQuery.data.length < 5) {
        return _onNotEnoughResults(titleQuery, query);
      } else {
        return titleQuery;
      }
    } else {
      return _database.search(SongSearch.byArtistName, argument: query);
    }
  }

  /// Searches artist name and combines the first query and the new query
  /// Complements the search function above and shouldn't be used alone
  Future<ListResponse<Song>> _onNotEnoughResults(
    ListResponse<Song> firstQuery,
    String query,
  ) async {
    final artistQuery = await _database.search(
      SongSearch.byArtistName,
      argument: query,
    );
    if (artistQuery.hasError) return firstQuery;
    firstQuery.data.addAll(artistQuery.data);
    // Remove any duplicate data points & keep list order
    final combinedData = firstQuery.data.toSet().toList();
    return ListResponse<Song>(data: combinedData);
  }
}
