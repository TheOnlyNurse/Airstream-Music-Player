import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';

import '../../global_assets.dart';
import '../extensions/functional_lists.dart';
import '../models/playlist_model.dart';
import '../providers/moor_database.dart';
import '../providers/playlist_provider.dart';
import 'scheduler.dart';
import 'server_repository.dart';

enum PlaylistChange { songsRemoved, songsAdded, fetched }

class PlaylistRepository {
  PlaylistRepository({
    PlaylistProvider mockProvider,
    Scheduler mockScheduler,
    ServerRepository mockServer,
  })  : _database =
            mockProvider ?? PlaylistProvider(hive: Hive.box('playlists')),
        _scheduler = mockScheduler ?? getIt.get<Scheduler>(),
        _server = mockServer ?? getIt.get<ServerRepository>();

  final PlaylistProvider _database;
  final Scheduler _scheduler;
  final ServerRepository _server;
  final _onChange = StreamController<PlaylistChange>.broadcast();

  /// A stream that changes when playlists change.
  Stream<PlaylistChange> get changed => _onChange.stream;

  /// Returns all playlists in alphabetical order.
  Either<String, List<Playlist>> byAlphabet() {
    return (_database.byAlphabet()).removeEmpty(_Error.playlistsEmpty);
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
  Future<Either<String, Playlist>> create(String name, String comment) async {
    await _scheduler.schedule('createPlaylist?name=$name');
    await forceSync();
    // Since we don't have the id, we have to get a playlist by it's name.
    return (_database.byName(name))
        .toEither(() => _Error.failedCreation)
        .map((playlist) {
      if (comment == null) return playlist;

      _database.changeComment(playlist.id, comment);
      _scheduler.schedule(
        'updatePlaylist?'
        'playlistId=${playlist.id}&'
        'comment=$comment',
      );
      return playlist.copyWith(comment: comment);
    });
  }

  /// Clears the local database in favour of one from the server.
  ///
  /// The information required to make a playlist class requires going through each
  /// playlist individually and the acquiring the song ids. Therefore, you can only "update"
  /// one playlist at a time.
  Future<void> forceSync() async {
    (await _server.allPlaylists()).fold(
      (error) => throw UnimplementedError(error),
      (elements) async {
        await _database.clear();
        final idList = elements.map((e) => int.parse(e.getAttribute('id')));

        for (final id in idList) {
          (await _server.playlist(id)).fold(
            (error) => throw UnimplementedError(error),
            (document) => _database.insertDocument(document),
          );
        }
      },
    );
  }
}

class _Error {
  _Error._();

  static const playlistsEmpty = 'No playlists found in local database.';

  static const failedCreation = 'Failed to create playlist.';
}
