import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Internal
import '../../models/playlist_model.dart';

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

  const PlaylistDialogSuccess(this.playlists, {this.currentView = 0});

  PlaylistDialogSuccess copyWith({
    List<Playlist> playlists,
    int currentView,
  }) =>
      PlaylistDialogSuccess(
        playlists ?? this.playlists,
        currentView: currentView ?? this.currentView,
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
