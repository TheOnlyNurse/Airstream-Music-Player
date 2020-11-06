/// External Packages
import 'package:hive/hive.dart';
import 'package:xml/xml.dart' as xml;

import '../models/playlist_model.dart';
import '../models/response/playlist_response.dart';
import 'scheduler.dart';
import 'server_provider.dart';

class PlaylistProvider {
  /// Private Variables
  Box<Playlist> get _hiveBox => Hive.box('playlists');

  /// Global Functions
  Future<PlaylistResponse> library({bool force = false}) async {
    if (force) await _downloadPlaylists();
    final playlists = _hiveBox.values.toList();
    if (playlists.isEmpty) {
      return _checkIfOnline(await _downloadPlaylists());
    } else {
      playlists.sort((a, b) => a.name.compareTo(b.name));
      return _checkIfOnline(
        PlaylistResponse(hasData: true, playlists: playlists),
      );
    }
  }

  void removeSongs(int id, List<int> removeIndexes) {
    final playlist = _hiveBox.get(id);
    for (int index in removeIndexes) {
      playlist.songIds.removeAt(index);
    }
    _update(playlist);
  }

  void addSongs(int id, List<int> songIdList) {
    final playlist = _hiveBox.get(id);
    playlist.songIds.addAll(songIdList);
    _update(playlist);
  }

  Future<PlaylistResponse> changeComment(int id, String comment) async {
    final newPlaylist = _hiveBox.get(id).copyWith(comment: comment);
    Scheduler().schedule('updatePlaylist?playlistId=$id&comment=$comment');
    _update(newPlaylist);
    return PlaylistResponse(hasData: true, playlist: newPlaylist);
  }

  /// Private Functions
  void _update(Playlist playlist) {
    _hiveBox.delete(playlist.id);
    _hiveBox.put(playlist.id, playlist);
  }

  Future<PlaylistResponse> _checkIfOnline(PlaylistResponse input) async {
    return input;

    /*
    if (Repository().settings.isOffline) {
			if (!input.hasData) return input;
			final availableList = <Playlist>[];
			final cache = await Repository().audioCache.cachedSongs();

			if (cache.hasNoData) return PlaylistResponse(passOn: cache);

			// If a playlist has at least one cached song, then add it to return list
			for (var playlist in input.playlists) {
				for (var songId in cache.idList) {
					if (playlist.songIds.contains(songId)) {
						availableList.add(playlist);
						break;
					}
				}
			}

      if (availableList.isEmpty) {
        return PlaylistResponse(error: 'No cached playlists');
      }
			return PlaylistResponse(hasData: true, playlists: availableList);
    }

    return input;

     */
  }

  Future<PlaylistResponse> _downloadPlaylists() async {
    final response = await ServerProvider().fetchXml('getPlaylists?');
    if (!response.hasData) return PlaylistResponse(passOn: response);
    _hiveBox.clear();
    final playlistArray = <Playlist>[];
    final idList = response.document
        .findAllElements('playlist')
        .map((element) => element.getAttribute('id'));

    for (var id in idList) {
      final playlist = await ServerProvider().fetchXml('getPlaylist?id=$id');
      if (!playlist.hasData) break;
      playlistArray.add(_updateWithXml(playlist.document));
    }

    if (playlistArray.isEmpty) {
      return PlaylistResponse(error: 'found no playlists on server');
    }

		return PlaylistResponse(hasData: true, playlists: playlistArray);
  }

  /// Update one playlist from a json map
  ///
  /// The information required to make a playlist class requires going through each
  /// playlist individually and the acquiring the song ids. Therefore, you can only "update"
  /// one playlist at a time.
  Playlist _updateWithXml(xml.XmlDocument playlistXml) {
    final playlist = Playlist.fromServer(playlistXml);
    _update(playlist);
    return playlist;
  }

  /// Singleton Boilerplate
  PlaylistProvider._internal();

  static final PlaylistProvider _instance = PlaylistProvider._internal();

  factory PlaylistProvider() => _instance;
}
