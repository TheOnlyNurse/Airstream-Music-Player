import 'dart:async';

import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

class PlaylistsScreenBloc extends Bloc<PlaylistsScreenEvent, PlaylistsScreenState> {
  StreamSubscription settingSS;
  StreamSubscription playlistSS;

  PlaylistsScreenBloc() {
    settingSS = Repository().settings.changed.listen((hasChanged) {
      if (hasChanged) this.add(PlaylistsScreenEvent.fetch);
    });
    playlistSS = Repository().playlist.changed.listen((event) {
      this.add(PlaylistsScreenEvent.fetch);
    });
  }

  @override
  PlaylistsScreenState get initialState => PlaylistsScreenInitial();

  @override
  Stream<PlaylistsScreenState> mapEventToState(PlaylistsScreenEvent event) async* {
    switch (event) {
      case PlaylistsScreenEvent.fetch:
        final response = await Repository().playlist.library();
        switch (response.status) {
          case DataStatus.ok:
            yield PlaylistsScreenSuccess(response.data);
            break;
          case DataStatus.error:
						yield PlaylistsScreenFailure(response.message);
            break;
        }
    }
  }

  @override
  Future<void> close() {
		playlistSS.cancel();
		settingSS.cancel();
		return super.close();
  }
}

enum PlaylistsScreenEvent { fetch }

abstract class PlaylistsScreenState {}

class PlaylistsScreenSuccess extends PlaylistsScreenState {
  final List<Playlist> playlistArray;

  PlaylistsScreenSuccess(this.playlistArray);
}

class PlaylistsScreenInitial extends PlaylistsScreenState {}

class PlaylistsScreenFailure extends PlaylistsScreenState {
  final Widget error;

  PlaylistsScreenFailure(this.error);
}
