import 'dart:async';

/// External Packages
import 'package:bloc/bloc.dart';

/// Internal links
import '../providers/repository/repository.dart';
import '../events/playlist_dialog_event.dart';
import '../states/playlist_dialog_state.dart';

// Ease of use barreling
export '../events/playlist_dialog_event.dart';
export '../states/playlist_dialog_state.dart';

class PlaylistDialogBloc
    extends Bloc<PlaylistDialogEvent, PlaylistDialogState> {

  PlaylistDialogBloc() : super(PlaylistDialogInitial());

  @override
  Stream<PlaylistDialogState> mapEventToState(
      PlaylistDialogEvent event) async* {
    final currentState = state;

    if (event is PlaylistDialogFetch) {
      final response = await Repository().playlist.library();
      if (response.hasData) {
        yield PlaylistDialogSuccess(response.playlists);
      } else {
        yield PlaylistDialogFailure(response.error);
      }
    }

    if (event is PlaylistDialogViewChange &&
        currentState is PlaylistDialogSuccess) {
      yield currentState.copyWith(currentView: event.currentView);
    }

    if (event is PlaylistDialogChosen) {
      yield PlaylistDialogComplete(event.playlist);
    }

    if (event is PlaylistDialogCreate) {
      yield PlaylistDialogInitial();
      final newPlaylist = await Repository().playlist.createPlaylist(
            event.name,
            event.comment,
          );
      if (newPlaylist.hasData) {
        this.add(PlaylistDialogChosen(newPlaylist.playlist));
      } else {
        yield PlaylistDialogFailure(newPlaylist.error);
      }
    }
  }
}
