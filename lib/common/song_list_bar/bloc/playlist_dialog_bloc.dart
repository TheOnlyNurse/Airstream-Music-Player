import 'dart:async';


import 'package:airstream/common/models/repository_response.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Internal links
import '../../repository/playlist_repository.dart';
import '../../models/playlist_model.dart';

part 'playlist_dialog_event.dart';

part 'playlist_dialog_state.dart';

class PlaylistDialogBloc
    extends Bloc<PlaylistDialogEvent, PlaylistDialogState> {
  PlaylistDialogBloc({@required this.playlistRepository})
      : assert(playlistRepository != null),
        super(PlaylistDialogInitial());

  final PlaylistRepository playlistRepository;

  @override
  Stream<PlaylistDialogState> mapEventToState(
      PlaylistDialogEvent event) async* {
    final currentState = state;

    if (event is PlaylistDialogFetch) {
      final response = playlistRepository.byAlphabet();
      if (response.hasData) {
        yield PlaylistDialogSuccess(response.data);
      } else {
        yield PlaylistDialogFailure(response);
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
      final newPlaylist = await playlistRepository.create(
            event.name,
            event.comment,
          );
      if (newPlaylist.hasData) {
        this.add(PlaylistDialogChosen(newPlaylist.data));
      } else {
        yield PlaylistDialogFailure(newPlaylist);
      }
    }
  }
}
