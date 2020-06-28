import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/data_providers/playlist_provider.dart';
import 'package:airstream/data_providers/scheduler.dart';

class PlaylistRepository {
  /// Private Variables
  final _provider = PlaylistProvider();
  final _scheduler = Scheduler();
  final StreamController<PlaylistChange> _onChange = StreamController.broadcast();

  /// Global Variables
  Stream<PlaylistChange> get changed => _onChange.stream;

  /// Global Functions
  Future<ProviderResponse> library({bool force = false}) async {
    final response = await _provider.library(force);

    if (force) _onChange.add(PlaylistChange.fetched);

    return response;
  }

  void removeSongs(Playlist playlist, List<int> indexList) async {
    var request = 'updatePlaylist?playlistId=${playlist.id}';
    for (int index in indexList) {
      request += '&songIndexToRemove=$index';
    }
    _scheduler.schedule(request);
    await _provider.removeSongs(playlist.id, indexList);
    _onChange.add(PlaylistChange.songsRemoved);
  }

  void addSongs(Playlist playlist, List<Song> songList) async {
    var request = 'updatePlaylist?playlistId=${playlist.id}';
    for (var song in songList) {
      request += '&songIdToAdd=${song.id}';
    }
    _scheduler.schedule(request);
    await _provider.addSongs(playlist.id, songList.map((e) => e.id).toList());
    _onChange.add(PlaylistChange.songsAdded);
  }

  Future<ProviderResponse> addPlaylist(String name, String comment) =>
      _provider.addPlaylist(name, comment);
}
