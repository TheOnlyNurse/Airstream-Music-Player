import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/audio_repository.dart';

part 'player_events.dart';

part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({AudioRepository audioRepository})
      : _audioRepository = audioRepository ?? GetIt.I.get<AudioRepository>(),
        super(PlayerInitial()) {
    _newSong = _audioRepository.songState.listen((_) => add(PlayerFetch()));
    _audioStopped = _audioRepository.audioState.listen((state) {
      if (state == AudioState.stopped) add(PlayerStopped());
    });
  }

  final AudioRepository _audioRepository;

  StreamSubscription _newSong;
  StreamSubscription _audioStopped;

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    final currentState = state;

    if (event is PlayerFetch) {
      final song = _audioRepository.current;
      yield song != null ? PlayerSuccess(song: song) : PlayerFailure();
    }

    if (event is PlayerStopped && currentState is PlayerSuccess) {
      yield currentState.copyWith(isFinished: true);
    }
  }

  @override
  Future<void> close() {
    _audioStopped.cancel();
    _newSong.cancel();
    return super.close();
  }
}
