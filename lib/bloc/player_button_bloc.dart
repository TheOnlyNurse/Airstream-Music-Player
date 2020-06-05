import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/player_button_event.dart';
import 'package:airstream/states/player_button_state.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerButtonBloc extends Bloc<PlayerButtonEvent, PlayerButtonState> {
  Repository _repository = Repository();
  final _assetsAudioPlayer = AssetsAudioPlayer.withId('airstream');
  StreamSubscription _audioEvents;
  StreamSubscription _audioFinished;
  StreamSubscription _percentageSS;

  PlayerButtonBloc() {
    _percentageSS = _repository.percentageStream.listen((event) {
      this.add(ButtonDownload(event.percent));
    });
    _audioEvents = _assetsAudioPlayer.isPlaying.listen((isPlaying) {
      print('isPlaying fired (${isPlaying}');
      if (isPlaying)
        this.add(ButtonAudioPlaying());
      else
        this.add(ButtonAudioPaused());
    });
    _audioFinished = _assetsAudioPlayer.playlistAudioFinished.listen((playing) {
      if (!playing.hasNext) this.add(ButtonAudioStopped());
    });
  }

  @override
  PlayerButtonState get initialState => ButtonNoAudio();

  @override
  Stream<PlayerButtonState> mapEventToState(PlayerButtonEvent event) async* {
    if (event is ButtonPlayPause) _assetsAudioPlayer.playOrPause();

    // React to Audio service event calls
    if (event is ButtonDownload) {
      yield ButtonIsDownloading(percentage: event.percentage);
    }
    if (event is ButtonAudioStopped) {
      yield ButtonNoAudio();
    }
    if (event is ButtonAudioPaused) {
      // Route out any false positive readings of the isPlaying boolean
      if (!(state is ButtonNoAudio)) {
        yield ButtonAudioIsPaused();
      }
    }
    if (event is ButtonAudioPlaying) {
      yield ButtonAudioIsPlaying();
    }
  }

  @override
  Future<void> close() {
    _audioFinished.cancel();
    _audioEvents.cancel();
    _percentageSS.cancel();
    return super.close();
  }
}
