import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../common/repository/audio_repository.dart';

enum PlayerControlsEvent {
  firstTrack,
  lastTrack,
  noNavigation,
  middleOfPlaylist
}

enum PlayerControlsState {
  noPrevious,
  noNext,
  noControls,
  allControls,
}

class PlayerControlsBloc
    extends Bloc<PlayerControlsEvent, PlayerControlsState> {
  PlayerControlsBloc({@required this.audioRepository})
      : super(PlayerControlsState.noControls) {
    // Load initial layout (primer)
    _originalLayout = _controlEvent;
    add(_originalLayout);

    _newTracks = audioRepository.songState.listen((state) {

        // Get new control structure
        _originalLayout = _controlEvent;
        add(_originalLayout);
        isRewindPossible = false;

    });
    _rewindPossible = audioRepository.audioPosition.listen((position) {
      if (position > const Duration(seconds: 5) && isRewindPossible == false) {
        _showRewindIsPossible();
        isRewindPossible = true;
      }
      if (position < const Duration(seconds: 5) && isRewindPossible) {
        isRewindPossible = false;
        add(_originalLayout);
      }
    });
  }

  final AudioRepository audioRepository;
  PlayerControlsEvent _originalLayout;
  bool isRewindPossible = false;
  StreamSubscription _rewindPossible;
  StreamSubscription _newTracks;

  PlayerControlsEvent get _controlEvent {
    final listLength = audioRepository.queueLength;
    final current = audioRepository.currentIndex;
    if (listLength == 1) return PlayerControlsEvent.noNavigation;
    if (current == 0) return PlayerControlsEvent.firstTrack;
    if (current + 1 == listLength) return PlayerControlsEvent.lastTrack;
    return PlayerControlsEvent.middleOfPlaylist;
  }

  void _showRewindIsPossible() {
    switch (_originalLayout) {
      case PlayerControlsEvent.firstTrack:
        add(PlayerControlsEvent.middleOfPlaylist);
        break;
      case PlayerControlsEvent.noNavigation:
        add(PlayerControlsEvent.lastTrack);
        break;
      default:
        break;
    }
  }

  @override
  Stream<PlayerControlsState> mapEventToState(
      PlayerControlsEvent event) async* {
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
    _newTracks.cancel();
    _rewindPossible.cancel();
    return super.close();
  }
}
