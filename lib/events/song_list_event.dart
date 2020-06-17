import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/models/playlist_model.dart';

abstract class SongListEvent {}

class SongListFetch extends SongListEvent {
  final dynamic typeValue;
  final SongListType type;
  final Function(bool hasSelection) callback;

  SongListFetch(this.type, this.typeValue, this.callback);
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