import 'dart:async';

import 'package:airstream/common/providers/server_provider.dart';
import 'package:airstream/common/global_assets.dart';
import 'package:meta/meta.dart';
import 'package:xml/xml.dart';

import '../models/playlist_model.dart';
import '../models/repository_response.dart';
import '../providers/moor_database.dart';
import '../providers/playlist_provider.dart';
import '../providers/scheduler.dart';
import 'communication.dart';

class PlaylistRepository {
  PlaylistRepository({
    @required PlaylistProvider provider,
    @required Scheduler scheduler,
    @required ServerProvider server,
  })  : assert(provider != null),
        assert(scheduler != null),
        assert(server != null),
        _scheduler = scheduler,
        _database = provider,
        _server = server;

  final PlaylistProvider _database;
  final Scheduler _scheduler;
  final ServerProvider _server;
  final _onChange = StreamController<PlaylistChange>.broadcast();

  /// A stream that changes when playlists change.
  Stream<PlaylistChange> get changed => _onChange.stream;

  /// Returns all playlists in alphabetical order.
  ListResponse<Playlist> byAlphabet() {
    final playlists = _database.byAlphabet();
    if (playlists.isEmpty) {
      return const ListResponse<Playlist>(
        error: 'No playlists found in local database.',
        solutions: [ErrorSolutions.database, ErrorSolutions.network],
      );
    } else {
      return ListResponse<Playlist>(data: playlists);
    }
  }

  /// Remove songs from an existing playlist.
  ///
  /// Songs removed are also scheduled to update the server.
  Future<void> removeSongs(Playlist playlist, List<int> indexList) async {
    final baseUrl = 'updatePlaylist?playlistId=${playlist.id}';
    final urlArguments = StringBuffer();
    for (final index in indexList) {
      urlArguments.write('&songIndexToRemove=$index');
    }
    await _database.removeSongs(playlist.id, indexList);
    _scheduler.schedule('$baseUrl${urlArguments.toString()}');
    _onChange.add(PlaylistChange.songsRemoved);
  }

  /// Adds songs to an existing playlist.
  Future<void> addSongs(Playlist playlist, List<Song> songList) async {
    final baseUrl = 'updatePlaylist?playlistId=${playlist.id}';
    final urlArguments = StringBuffer();
    for (final song in songList) {
      urlArguments.write('&songIdToAdd=${song.id}');
    }
    await _database.addSongs(playlist.id, songList.map((e) => e.id).toList());
    _scheduler.schedule('$baseUrl${urlArguments.toString()}');
    _onChange.add(PlaylistChange.songsAdded);
  }

  /// Creates a playlist.
  ///
  /// Since the id required to stay in sync with the server is created by the
  /// server, an active connection is required.
  Future<SingleResponse<Playlist>> create(String name, String comment) async {
    await _scheduler.schedule('createPlaylist?name=$name');
    await forceSync();
    // Since we don't have the id, we have to get a playlist by it's name.
    final created = _database.byName(name);
    if (created == null) {
      return const SingleResponse(error: 'Creation failed.');
    }

    if (comment != null) {
      _database.changeComment(created.id, comment);
      await _scheduler.schedule(
        'updatePlaylist?'
        'playlistId=${created.id}&'
        'comment=$comment',
      );
      return SingleResponse<Playlist>(data: created.copyWith(comment: comment));
    } else {
      return SingleResponse<Playlist>(data: created);
    }

  }

  /// Clears the local database in favour of one from the server.
  ///
  /// The information required to make a playlist class requires going through each
  /// playlist individually and the acquiring the song ids. Therefore, you can only "update"
  /// one playlist at a time.
  Future<void> forceSync() async {
    final allPlaylists = await _server.fetchXml('getPlaylists?');
    if (allPlaylists.hasError) throw UnimplementedError();
    await _database.clear();
    final idList = allPlaylists.data
        .findAllElements('playlist')
        .map((element) => element.getAttribute('id'));

    for (final id in idList) {
      final playlist = await ServerProvider().fetchXml('getPlaylist?id=$id');
      if (playlist.hasError) break;
      _database.insertElement(playlist.data);
    }
  }
}
