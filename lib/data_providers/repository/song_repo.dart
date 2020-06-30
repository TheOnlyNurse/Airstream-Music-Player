part of repository_library;

class _SongRepository {
  _SongRepository({@required this.dao}) : assert(dao != null);

  final SongsDao dao;

  /// Stream controller when songs database changes state
  final StreamController<SongChange> _onChange = StreamController.broadcast();

  /// Listenable stream of database state
  Stream<SongChange> get changed => _onChange.stream;

  /// Returns a song list (with on item) by id
  Future<SongResponse> byId(int id) {
    return dao.search(SongSearch.byId, argument: id);
  }

  /// Get starred songs
  Future<SongResponse> starred() => dao.search(SongSearch.byStarred);

  /// Forcefully updates starred songs
  Future<SongResponse> updateStarred() {
    return dao.updateStarred();
  }

  /// Get songs in a given album
  Future<SongResponse> fromAlbum(Album album) {
    return dao.search(SongSearch.byAlbum, argument: album.id);
  }

  /// Convert playlist song id list to song details from database
  Future<SongResponse> fromPlaylist(Playlist playlist) async {
    final songList = <Song>[];
    ProviderResponse lastError;

    for (int id in playlist.songIds) {
      final query = await dao.search(SongSearch.byId, argument: id);
      if (query.hasNoData) {
        lastError = query;
        continue;
      }
      songList.add(query.songList.first);
    }

    if (songList.isNotEmpty) {
      return SongResponse(hasData: true, songList: songList);
    } else if (lastError != null) {
      return SongResponse(passOn: lastError);
    } else {
      return SongResponse(error: 'No songs found in playlist');
    }
  }

  /// Searches both song titles and artist names
  /// Searches artist names
  ///  1. When searching song titles returns less than 5 results
  ///  2. When song titles returns no results
  Future<SongResponse> search({String query}) async {
    final titleQuery = await dao.search(SongSearch.byTitle, argument: query);
    if (titleQuery.hasData) {
      if (titleQuery.songList.length < 5) {
        return _onNotEnoughResults(titleQuery);
      } else {
        return titleQuery;
      }
    } else {
      return dao.search(SongSearch.byArtistName, argument: query);
    }
  }

  /// Searches artist name and combines the first query and the new query
  Future<SongResponse> _onNotEnoughResults(SongResponse firstQuery) async {
    final artistQuery = await dao.search(
      SongSearch.byArtistName,
      argument: search,
    );
    if (artistQuery.hasNoData) return firstQuery;
    firstQuery.songList.addAll(artistQuery.songList);
    // Remove any duplicate data points & keep list order
    final combinedData = LinkedHashSet<Song>.from(firstQuery.songList).toList();
    return SongResponse(hasData: true, songList: combinedData);
  }

  /// Change a list of song stars
  void star({@required List<Song> songList, bool toStar = false}) async {
    for (var song in songList) {
      await dao.changeStar(song.id, toStar);
    }

    if (toStar) {
      _onChange.add(SongChange.starred);
    } else {
      _onChange.add(SongChange.unstarred);
    }
  }
}
