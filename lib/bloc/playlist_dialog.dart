import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class PlaylistDialogBloc extends Bloc<PlaylistDialogEvent, PlaylistDialogState> {
  @override
  PlaylistDialogState get initialState => PlaylistDialogInitial();

  @override
  Stream<PlaylistDialogState> mapEventToState(PlaylistDialogEvent event) async* {
    final currentState = state;

    if (event is PlaylistDialogFetch) {
      final ProviderResponse response = await Repository().playlist.library();
      switch (response.status) {
        case DataStatus.ok:
          yield PlaylistDialogSuccess(response.data, 0);
          break;
        case DataStatus.error:
          yield PlaylistDialogFailure(response.message);
          break;
      }
    }

    if (event is PlaylistDialogViewChange && currentState is PlaylistDialogSuccess) {
      yield currentState.copyWith(currentView: event.currentView);
    }

    if (event is PlaylistDialogChosen) {
      yield PlaylistDialogComplete(event.playlist);
    }

    if (event is PlaylistDialogCreate) {
      yield PlaylistDialogInitial();
      final newPlaylist = await Repository().playlist.addPlaylist(
            event.name,
            event.comment,
          );
      if (newPlaylist.status == DataStatus.ok)
        this.add(PlaylistDialogChosen(newPlaylist.data));
      else
        yield PlaylistDialogFailure(newPlaylist.message);
    }
  }
}

abstract class PlaylistDialogEvent extends Equatable {
  const PlaylistDialogEvent();

  @override
  List<Object> get props => [];
}

class PlaylistDialogFetch extends PlaylistDialogEvent {}

class PlaylistDialogViewChange extends PlaylistDialogEvent {
  final int currentView;

  const PlaylistDialogViewChange(this.currentView);
}

class PlaylistDialogChosen extends PlaylistDialogEvent {
  final Playlist playlist;

  const PlaylistDialogChosen(this.playlist);
}

class PlaylistDialogCreate extends PlaylistDialogEvent {
  final String name;
  final String comment;

  const PlaylistDialogCreate(this.name, this.comment);
}

abstract class PlaylistDialogState extends Equatable {
  const PlaylistDialogState();

  @override
  List<Object> get props => [];
}

class PlaylistDialogInitial extends PlaylistDialogState {}

class PlaylistDialogSuccess extends PlaylistDialogState {
  final List<Playlist> playlists;
  final int currentView;

  @override
  List<Object> get props => [currentView];

  const PlaylistDialogSuccess(this.playlists, this.currentView);

  PlaylistDialogSuccess copyWith({
    List<Playlist> playlists,
    int currentView,
  }) =>
      PlaylistDialogSuccess(
        playlists ?? this.playlists,
        currentView ?? this.currentView,
      );
}

class PlaylistDialogFailure extends PlaylistDialogState {
  final Widget message;

  const PlaylistDialogFailure(this.message);
}

class PlaylistDialogComplete extends PlaylistDialogState {
  final Playlist playlist;

  const PlaylistDialogComplete(this.playlist);
}
