import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../common/global_assets.dart';
import '../../../common/models/playlist_model.dart';
import '../../../common/models/repository_response.dart';
import '../../../common/repository/playlist_repository.dart';
import '../../../common/repository/settings_repository.dart';

class PlaylistsLibraryBloc
    extends Bloc<PlaylistsLibraryEvent, PlaylistsLibraryState> {
  PlaylistsLibraryBloc({PlaylistRepository playlist, SettingsRepository settings,})
      : _playlist = getIt<PlaylistRepository>(playlist),
  _settings = getIt<SettingsRepository>(settings),
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
        final response = _playlist.byAlphabet();
        if (response.hasData) {
          yield PlaylistsLibrarySuccess(response.data);
        } else {
          yield PlaylistsLibraryFailure(response);
        }
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
  final RepositoryResponse response;

  PlaylistsLibraryFailure(this.response);
}
