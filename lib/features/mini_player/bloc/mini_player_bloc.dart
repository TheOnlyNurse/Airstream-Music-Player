import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../common/repository/communication.dart';
import '../../../common/repository/repository.dart';

part 'mini_player_event.dart';
part 'mini_player_state.dart';

class MiniPlayerBloc extends Bloc<MiniPlayerEvent, MiniPlayerState> {
  MiniPlayerBloc({
    @required double screenHeight,
    @required NavigatorState navigator,
  })  : assert(screenHeight != null),
        assert(navigator != null),
        _navigator = navigator,
        _screenHeight = screenHeight.floor(),
        super(MiniPlayerHidden()) {
    _audioEvents = _repository.audio.playerState.listen((state) {
      switch (state) {
        case AudioPlayerState.playing:
          add(MiniPlayerPlaying());
          break;
        case AudioPlayerState.paused:
          add(MiniPlayerPaused());
          break;
        case AudioPlayerState.stopped:
          add(MiniPlayerStopped());
          break;
      }
    });
  }

  final _repository = Repository();
  final int _screenHeight;
  final NavigatorState _navigator;
  StreamSubscription _audioEvents;

  @override
  Stream<MiniPlayerState> mapEventToState(MiniPlayerEvent event) async* {
    final currentState = state;

    if (currentState is MiniPlayerShown) {
      if (event is MiniPlayerPlayPause) {
        if (currentState.isPlaying) {
          _repository.audio.pause();
        } else {
          _repository.audio.play();
        }
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
