import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/playlist_model.dart';
import '../../models/repository_response.dart';
import '../../repository/playlist_repository.dart';

part 'playlist_dialog_state.dart';

class PlaylistDialogCubit extends Cubit<PlaylistDialogState> {
  PlaylistDialogCubit({@required this.playlistRepository})
      : assert(playlistRepository != null),
        super(PlaylistDialogInitial());

  final PlaylistRepository playlistRepository;

  void fetch() {
    final response = playlistRepository.byAlphabet();
    if (response.hasData) {
      emit(PlaylistDialogSuccess(response.data));
    } else {
      emit(PlaylistDialogFailure(response));
    }
  }

  void pageChange(int index) {
    final currentState = state;
    if (currentState is PlaylistDialogSuccess) {
      emit(currentState.copyWith(index: index));
    }
  }

  Future<void> create(String name, String comment) async {
    emit(PlaylistDialogInitial());
    final newPlaylist = await playlistRepository.create(name, comment);
    if (newPlaylist.hasData) {
      selected(newPlaylist.data);
    } else {
      emit(PlaylistDialogFailure(newPlaylist));
    }
  }

  void selected(Playlist playlist) => emit(PlaylistDialogComplete(playlist));
}
