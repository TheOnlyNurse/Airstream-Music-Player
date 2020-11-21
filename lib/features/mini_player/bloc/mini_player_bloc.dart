import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../common/repository/audio_repository.dart';

import 'mini_player_event.dart';
import 'mini_player_state.dart';

export 'mini_player_event.dart';
export 'mini_player_state.dart';

class MiniPlayerBloc extends Bloc<MiniPlayerEvent, MiniPlayerState> {
  MiniPlayerBloc({
    @required double screenHeight,
    @required NavigatorState navigator,
    @required this.audioRepository,
  })  : assert(screenHeight != null),
        assert(navigator != null),
        _navigator = navigator,
        _screenHeight = screenHeight.floor(),
        super(MiniPlayerHidden()) {
    _audioEvents = audioRepository.audioState.listen((state) {
      switch (state) {
        case AudioState.playing:
          add(MiniPlayerPlaying());
          break;
        case AudioState.paused:
          add(MiniPlayerPaused());
          break;
        case AudioState.stopped:
          add(MiniPlayerStopped());
          break;
      }
    });
  }

  final AudioRepository audioRepository;
  final int _screenHeight;
  final NavigatorState _navigator;
  StreamSubscription _audioEvents;

  @override
  Stream<MiniPlayerState> mapEventToState(MiniPlayerEvent event) async* {
    final currentState = state;

    if (currentState is MiniPlayerShown) {
      if (event is MiniPlayerPlayPause) {
        audioRepository.playPause();
      }

      if (event is MiniPlayerDragEnd) {
        if (_screenHeight - event.screenOffset > 200) {
          _navigator.pushNamed('/musicPlayer');
        }
        yield currentState.copyWith(isMoving: false);
      }

      if (event is MiniPlayerDragStarted) {
        yield currentState.copyWith(isMoving: true);
      }
    }

    if (event is MiniPlayerStopped) {
      yield MiniPlayerHidden();
    }
    if (event is MiniPlayerPlaying) {
      yield const MiniPlayerShown(isPlaying: true);
    }
    if (event is MiniPlayerPaused) {
      yield const MiniPlayerShown(isPlaying: false);
    }
  }

  @override
  Future<void> close() {
    _audioEvents.cancel();
    return super.close();
  }
}
