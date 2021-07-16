import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../common/models/playlist_model.dart';
import '../../../common/repository/playlist_repository.dart';
import '../../../common/repository/settings_repository.dart';
import '../../../global_assets.dart';

class PlaylistsLibraryBloc
    extends Bloc<PlaylistsLibraryEvent, PlaylistsLibraryState> {
  PlaylistsLibraryBloc({
    PlaylistRepository mockPlaylistRepo,
    SettingsRepository mockSettingsRepo,
  })  : _playlist = mockPlaylistRepo ?? getIt.get<PlaylistRepository>(),
        _settings = mockSettingsRepo ?? getIt.get<SettingsRepository>(),
        super(PlaylistsLibraryInitial()) {
    onNetworkChange = _settings.connectivityChanged.listen((isOnline) {
      if (isOnline) add(PlaylistsLibraryEvent.fetch);
    });
    onPlaylistChange = _playlist.changed.listen((event) {
      add(PlaylistsLibraryEvent.fetch);
    });
  }

  final PlaylistRepository _playlist;
  final SettingsRepository _settings;
  StreamSubscription onNetworkChange;
  StreamSubscription onPlaylistChange;

  @override
  Stream<PlaylistsLibraryState> mapEventToState(
      PlaylistsLibraryEvent event) async* {
    switch (event) {
      case PlaylistsLibraryEvent.fetch:
        yield (_playlist.byAlphabet()).fold(
          (error) => PlaylistsLibraryFailure(error),
          (playlists) => PlaylistsLibrarySuccess(playlists),
        );
    }
  }

  @override
  Future<void> close() {
    onPlaylistChange.cancel();
    onNetworkChange.cancel();
    return super.close();
  }
}

enum PlaylistsLibraryEvent { fetch }

abstract class PlaylistsLibraryState {}

class PlaylistsLibrarySuccess extends PlaylistsLibraryState {
  final List<Playlist> playlistArray;

  PlaylistsLibrarySuccess(this.playlistArray);
}

class PlaylistsLibraryInitial extends PlaylistsLibraryState {}

class PlaylistsLibraryFailure extends PlaylistsLibraryState {
  final String message;

  PlaylistsLibraryFailure(this.message);
}
