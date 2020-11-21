import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../models/playlist_model.dart';
import '../../repository/playlist_repository.dart';

import 'playlist_dialog_state.dart';
export 'playlist_dialog_state.dart';

class PlaylistDialogCubit extends Cubit<PlaylistDialogState> {
  PlaylistDialogCubit({@required this.playlistRepository})
      : assert(playlistRepository != null),
        super(PlaylistDialogInitial());

  final PlaylistRepository playlistRepository;

  void fetch() {
    playlistRepository.byAlphabet().fold(
        (error) => emit(PlaylistDialogFailure(error)),
        (playlists) => emit(PlaylistDialogSuccess(playlists)));
  }

  void pageChange(int index) {
    final currentState = state;
    if (currentState is PlaylistDialogSuccess) {
      emit(currentState.copyWith(index: index));
    }
  }

  Future<void> create(String name, String comment) async {
    emit(PlaylistDialogInitial());
    (await playlistRepository.create(name, comment)).fold(
      (error) => emit(PlaylistDialogFailure(error)),
      (playlist) => selected(playlist),
    );
  }

  void selected(Playlist playlist) => emit(PlaylistDialogComplete(playlist));
}
