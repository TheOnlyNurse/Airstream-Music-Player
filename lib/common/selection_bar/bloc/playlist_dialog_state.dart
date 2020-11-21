part of 'playlist_dialog_cubit.dart';

abstract class PlaylistDialogState extends Equatable {
  const PlaylistDialogState() : super();

  @override
  List<Object> get props => [];
}

class PlaylistDialogInitial extends PlaylistDialogState {}

class PlaylistDialogSuccess extends PlaylistDialogState {
  final List<Playlist> playlists;
  final int index;

  @override
  List<Object> get props => [index];

  const PlaylistDialogSuccess(this.playlists, {this.index = 0});

  PlaylistDialogSuccess copyWith({
    List<Playlist> playlists,
    int index,
  }) =>
      PlaylistDialogSuccess(
        playlists ?? this.playlists,
        index: index ?? this.index,
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
