part of 'playlist_dialog_bloc.dart';

abstract class PlaylistDialogState extends Equatable {
  const PlaylistDialogState() : super();

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
  final RepositoryResponse response;

  const PlaylistDialogFailure(this.response);
}

class PlaylistDialogComplete extends PlaylistDialogState {
  final Playlist playlist;

  const PlaylistDialogComplete(this.playlist);
}
