part of repository_library;

class _PlaylistRepository {
  /// Private Variables
  final _provider = PlaylistProvider();
  final _scheduler = Scheduler();
  final StreamController<PlaylistChange> _onChange =
      StreamController.broadcast();

  /// Global Variables
  Stream<PlaylistChange> get changed => _onChange.stream;

  /// Global Functions
  Future<PlaylistResponse> library({bool force = false}) async {
    final response = await _provider.library(force: force);
    if (force) _onChange.add(PlaylistChange.fetched);
    return response;
  }

  void removeSongs(Playlist playlist, List<int> indexList) async {
    var request = 'updatePlaylist?playlistId=${playlist.id}';
    for (int index in indexList) {
      request += '&songIndexToRemove=$index';
    }
    _scheduler.schedule(request);
    _provider.removeSongs(playlist.id, indexList);
    _onChange.add(PlaylistChange.songsRemoved);
  }

  void addSongs(Playlist playlist, List<Song> songList) async {
		var request = 'updatePlaylist?playlistId=${playlist.id}';
		for (var song in songList) {
			request += '&songIdToAdd=${song.id}';
		}
		_scheduler.schedule(request);
		_provider.addSongs(playlist.id, songList.map((e) => e.id).toList());
		_onChange.add(PlaylistChange.songsAdded);
  }

	Future<PlaylistResponse> createPlaylist(String name, String comment) async {
		await Scheduler().schedule('createPlaylist?name=$name');
    final response = await library(force: true);
    if (!response.hasData) return response;
    final createdPlaylist = response.playlists.firstWhere((p) {
      return p.name == name;
    });
    return _provider.changeComment(createdPlaylist.id, comment);
  }
}
