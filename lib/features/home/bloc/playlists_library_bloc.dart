import 'dart:async';


import 'package:airstream/common/models/repository_response.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

/// Internal links
import '../../../common/repository/communication.dart';
import '../../../common/repository/playlist_repository.dart';
import '../../../common/models/playlist_model.dart';
import '../../../common/providers/repository/repository.dart';

class PlaylistsLibraryBloc
    extends Bloc<PlaylistsLibraryEvent, PlaylistsLibraryState> {
  PlaylistsLibraryBloc({@required this.playlistRepository})
      : assert(playlistRepository != null),
        super(PlaylistsLibraryInitial()) {
    onNetworkChange = Repository().settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(PlaylistsLibraryEvent.fetch);
    });
    onPlaylistChange = playlistRepository.changed.listen((event) {
      this.add(PlaylistsLibraryEvent.fetch);
    });
  }

  final PlaylistRepository playlistRepository;
  StreamSubscription onNetworkChange;
  StreamSubscription onPlaylistChange;

  @override
  Stream<PlaylistsLibraryState> mapEventToState(
      PlaylistsLibraryEvent event) async* {
    switch (event) {
      case PlaylistsLibraryEvent.fetch:
        final response = playlistRepository.byAlphabet();
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
