import 'dart:async';

import 'package:airstream/data_providers/repository.dart';
import 'package:bloc/bloc.dart';

enum PlayerControlsEvent { firstTrack, lastTrack, noNavigation, middleOfPlaylist }

enum PlayerControlsState { noPrevious, noNext, noControls, allControls }

class PlayerControlsBloc extends Bloc<PlayerControlsEvent, PlayerControlsState> {
  final _audioPlayer = Repository().audioPlayer;
  PlayerControlsEvent _lastEvent;
  String _lastPlayed;
  bool isRewindPossible = false;
  StreamSubscription _rewindPossibleSS;
  StreamSubscription _newTracksSS;

  PlayerControlsEvent _getControlEvent() {
    final listLength = Repository().playlistLength;
    final current = Repository().currentIndex;
    if (listLength == 1) return PlayerControlsEvent.noNavigation;
    if (current == 0) return PlayerControlsEvent.firstTrack;
    if (current + 1 == listLength) return PlayerControlsEvent.lastTrack;
    return PlayerControlsEvent.middleOfPlaylist;
  }

  void _showRewindIsPossible() {
    switch (_lastEvent) {
      case PlayerControlsEvent.firstTrack:
        this.add(PlayerControlsEvent.middleOfPlaylist);
        break;
      case PlayerControlsEvent.noNavigation:
        this.add(PlayerControlsEvent.lastTrack);
        break;
      default:
        break;
    }
  }

  PlayerControlsBloc() {
    _newTracksSS = _audioPlayer.current.listen((playing) {
      if (playing != null && _lastPlayed != playing.audio.audio.path) {
        _lastPlayed = playing.audio.audio.path;
        _lastEvent = _getControlEvent();
        this.add(_lastEvent);
        isRewindPossible = false;
      }
    });
    _rewindPossibleSS = _audioPlayer.currentPosition.listen((position) {
      if (position > Duration(seconds: 5) && isRewindPossible == false) {
        _showRewindIsPossible();
        isRewindPossible = true;
      }
      if (position < Duration(seconds: 5) && isRewindPossible) {
        isRewindPossible = false;
        this.add(_lastEvent);
      }
    });
  }

  @override
  PlayerControlsState get initialState => PlayerControlsState.noControls;

  @override
  Stream<PlayerControlsState> mapEventToState(PlayerControlsEvent event) async* {
    switch (event) {
      case PlayerControlsEvent.middleOfPlaylist:
        yield PlayerControlsState.allControls;
        break;
      case PlayerControlsEvent.firstTrack:
        yield PlayerControlsState.noPrevious;
        break;
      case PlayerControlsEvent.lastTrack:
        yield PlayerControlsState.noNext;
        break;
      case PlayerControlsEvent.noNavigation:
        yield PlayerControlsState.noControls;
        break;
    }
  }

  @override
  Future<void> close() {
    _newTracksSS.cancel();
    _rewindPossibleSS.cancel();
    return super.close();
  }
}
