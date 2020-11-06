import 'dart:async';

/// External Packages
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

/// Internal links
import '../repository/communication.dart';
import '../providers/repository/repository.dart';
import '../models/playlist_model.dart';

class PlaylistsLibraryBloc
    extends Bloc<PlaylistsLibraryEvent, PlaylistsLibraryState> {
  final _repository = Repository();
  StreamSubscription onNetworkChange;
  StreamSubscription onPlaylistChange;

  PlaylistsLibraryBloc() : super(PlaylistsLibraryInitial()) {
    onNetworkChange = _repository.settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(PlaylistsLibraryEvent.fetch);
    });
    onPlaylistChange = _repository.playlist.changed.listen((event) {
      this.add(PlaylistsLibraryEvent.fetch);
    });
  }

  @override
  Stream<PlaylistsLibraryState> mapEventToState(
      PlaylistsLibraryEvent event) async* {
    switch (event) {
      case PlaylistsLibraryEvent.fetch:
        final response = await _repository.playlist.library();
        if (response.hasData) {
          yield PlaylistsLibrarySuccess(response.playlists);
        } else {
          yield PlaylistsLibraryFailure(response.error);
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
  final Widget error;

  PlaylistsLibraryFailure(this.error);
}
