import 'dart:async';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class PlaylistsLibraryBloc extends Bloc<PlaylistsLibraryEvent, PlaylistsLibraryState> {
  StreamSubscription settingsChange;
  StreamSubscription playlistChange;

  PlaylistsLibraryBloc() {
    settingsChange = Repository().settings.changed.listen((hasChanged) {
      if (hasChanged) this.add(PlaylistsLibraryEvent.fetch);
    });
    playlistChange = Repository().playlist.changed.listen((event) {
      this.add(PlaylistsLibraryEvent.fetch);
    });
  }

  @override
  PlaylistsLibraryState get initialState => PlaylistsLibraryInitial();

  @override
  Stream<PlaylistsLibraryState> mapEventToState(PlaylistsLibraryEvent event) async* {
    switch (event) {
      case PlaylistsLibraryEvent.fetch:
        final response = await Repository().playlist.library();
        switch (response.status) {
          case DataStatus.ok:
            yield PlaylistsLibrarySuccess(response.data);
            break;
          case DataStatus.error:
            yield PlaylistsLibraryFailure(response.message);
            break;
        }
    }
  }

  @override
  Future<void> close() {
    playlistChange.cancel();
    settingsChange.cancel();
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
