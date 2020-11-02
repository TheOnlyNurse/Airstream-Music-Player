import 'package:airstream/repository/artist_repository.dart';
import 'package:flutter/foundation.dart';

/// Internal
import '../models/playlist_model.dart';
import '../models/repository_response.dart';
import '../providers/moor_database.dart';
import '../providers/songs_dao.dart';

class SongRepository {
  SongRepository({
    @required SongsDao songsDao,
    @required ArtistRepository artistRepository,
  })  : assert(songsDao != null),
        assert(artistRepository != null),
        _database = songsDao,
        _artistRepository = artistRepository;

  final ArtistRepository _artistRepository;
  final SongsDao _database;

  /// ========== QUERYING ==========

  /// Returns a song by id.
  Future<SingleResponse<Song>> byId(int id) async {
    var song = await _database.byId(id);
    return song != null ? SingleResponse<Song>(data: song) : null;
  }

  /// Get songs that match a given album.
  ///
  /// Fetches from the server if the number of songs retrieved doesn't match
  /// the songs expected in the album.
  Future<ListResponse<Song>> byAlbum(Album album) async {
    var songs = await _database.byAlbum(album.id);
    if (songs.length != album.songCount) {
      // TODO: Fetch album and add results into the database
      throw UnimplementedError();
    } else {
      return ListResponse(data: songs);
    }
  }

  /// Convert playlist song id list to song details from database.
  Future<ListResponse<Song>> byPlaylist(Playlist playlist) async {
    var songs = await _database.byIdList(playlist.songIds);
    if (songs.length != playlist.songIds.length) {
      // TODO: Fetch songs in playlist
      throw UnimplementedError();
    } else {
      return ListResponse<Song>(data: songs);
    }
  }

  Future<ListResponse<Song>> starred() {
    // TODO: Merge Starred Provider and Song Repo
    throw UnimplementedError();
  }

  Future<ListResponse<Song>> topSongsOf(Artist artist) async {
    var songIds = await _artistRepository.topSongIds(artist);
    if (songIds.hasError) {
      // TODO: Fetch top songs of a given artist
      // TODO: If the fetched list is empty, fill the list with the songs available
      // TODO: Cache the generated list in the artist repository
    }

    var songs = await _database.byIdList(songIds.data);
    if (songs.length != songIds.data.length) {
      // TODO: Fetch song ids from the server
      throw UnimplementedError();
    } else {
      return ListResponse<Song>(data: songs);
    }
  }

  /// Searches both titles and artist names assigned to songs by a query string.
  Future<ListResponse<Song>> search({String query}) async {
    var byTitle = await _database.byTitle(query);
    var byName = await _database.byArtistName(query);
    var songs = [...byTitle, ...byName];

    if (songs.length < 5) {
      // TODO: Return search results from the server query
      // TODO: Default to local results if the server query is insufficient
      throw UnimplementedError();
    } else {
      return ListResponse<Song>(data: songs);
    }
  }
}

/* There be dragons beyond!

  /// Fetches top songs of a given artist from either a hive box or the server
  Future<ListResponse<Song>> topSongsOf(Artist artist) async {
    final _hiveBox = Hive.box('topSongs');
    List<int> cachedIdList = _hiveBox.get(artist.id);
    if (cachedIdList == null) {
      final name = artist.name.replaceAll(' ', '+');
      final response = await ServerProvider().fetchXml(
        'getTopSongs?artist=$name&count=5',
      );
      if (response.hasData) {
        final elements = response.document.findAllElements('song');
        cachedIdList = elements.map((e) {
          return int.parse(e.getAttribute('id'));
        }).toList();
        _hiveBox.put(artist.id, cachedIdList);
      } else {
        cachedIdList = [];
      }
    }

    final songs = await byIdList(cachedIdList);
    if (songs.isEmpty) {
      return ListResponse<Song>(error: 'Failed to find artist\'s top songs.');
    } else {
      return ListResponse<Song>(data: songs);
    }
  }
    /// Request to get songs by searching a query
  Future<ServerResponse> _downloadSearch(String query) {
    return ServerProvider().fetchXml('search3?query=$query'
        '&songCount=10'
        '&artistCount=0'
        '&albumCount=0');
  }

 */
