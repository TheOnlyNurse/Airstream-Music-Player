import 'dart:async';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bloc/bloc.dart';

enum PlayButtonEvent { fetch, playPause, playAudio, pauseAudio }

enum PlayButtonState { audioPlaying, audioPaused }

class PlayButtonBloc extends Bloc<PlayButtonEvent, PlayButtonState> {
  final _assetsAudioPlayer = AssetsAudioPlayer.withId('airstream');
  StreamSubscription _audioEvents;

  PlayButtonBloc() {
    _audioEvents = _assetsAudioPlayer.isPlaying.listen((isPlaying) {
      if (isPlaying)
        this.add(PlayButtonEvent.playAudio);
      else
        this.add(PlayButtonEvent.pauseAudio);
    });
  }

  @override
  PlayButtonState get initialState => PlayButtonState.audioPlaying;

  @override
  Stream<PlayButtonState> mapEventToState(PlayButtonEvent event) async* {
    switch (event) {
      case PlayButtonEvent.fetch:
        yield _assetsAudioPlayer.isPlaying.value
            ? PlayButtonState.audioPlaying
            : PlayButtonState.audioPaused;
        break;
      case PlayButtonEvent.playPause:
        _assetsAudioPlayer.playOrPause();
        break;
      case PlayButtonEvent.pauseAudio:
        yield PlayButtonState.audioPaused;
        break;
      case PlayButtonEvent.playAudio:
        yield PlayButtonState.audioPlaying;
        break;
    }
  }

  @override
  Future<void> close() {
    _audioEvents.cancel();
    return super.close();
  }
}
