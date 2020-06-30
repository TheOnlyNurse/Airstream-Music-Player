import 'package:airstream/models/playlist_model.dart';
import 'package:equatable/equatable.dart';

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
