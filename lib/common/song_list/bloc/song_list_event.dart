part of 'song_list_bloc.dart';

abstract class SongListEvent {}

class SongListFetch extends SongListEvent {
  final delegate;

  SongListFetch(this.delegate);
}

class SongListSelection extends SongListEvent {
  final int index;

  SongListSelection(this.index);
}

class SongListClearSelection extends SongListEvent {}

class SongListStarSelection extends SongListEvent {}

class SongListPlaylistSelection extends SongListEvent {
  final Playlist playlist;

  SongListPlaylistSelection(this.playlist);
}

class SongListRemoveSelection extends SongListEvent {}