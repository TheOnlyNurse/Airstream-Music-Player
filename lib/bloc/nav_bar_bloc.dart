import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  StreamSubscription _audioSS;
  StreamSubscription _downloadSS;
  bool notchDisplayed = false;

  NavigationBarBloc() {
    _audioSS = Repository().audioPlayer.playerState.listen((state) {
      if (state == PlayerState.play) this.add(NavigationBarMusicStarted());
      if (state == PlayerState.stop) {
        this.add(NavigationBarMusicStopped());
        notchDisplayed = false;
      }
    });
    _downloadSS = Repository().percentageStream.listen((event) {
      if (!notchDisplayed) {
        this.add(NavigationBarMusicStarted());
        notchDisplayed = true;
      }
    });
  }

  @override
  NavigationBarState get initialState =>
      NavigationBarLoaded(index: 0, musicPlaying: false);

  @override
  Stream<NavigationBarState> mapEventToState(NavigationBarEvent event) async* {
    final currentState = state;

    if (currentState is NavigationBarLoaded) {
      if (event is NavigationBarNavigate)
        yield currentState.copyWith(index: event.index, isNewDisplay: true);
      if (event is NavigationBarUpdate) yield currentState.copyWith(index: event.index);

      if (event is NavigationBarDrag) {
        if (event.height < 60 && event.height > 30) {
          yield currentState.copyWith(barHeight: 125);
        }
        if (event.height < 125 && event.height > 61)
          yield currentState.copyWith(barHeight: 60);
      }
      if (event is NavigationBarMusicStopped)
        yield currentState.copyWith(musicPlaying: false);
      if (event is NavigationBarMusicStarted)
        yield currentState.copyWith(musicPlaying: true);
    }
  }

  @override
  Future<void> close() {
    _downloadSS.cancel();
    _audioSS.cancel();
    return super.close();
  }
}
