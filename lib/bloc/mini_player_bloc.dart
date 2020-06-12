import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/mini_player_event.dart';
import 'package:airstream/states/mini_player_state.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class MinimisedPlayerBloc extends Bloc<MinimisedPlayerEvent, MinimisedPlayerState> {
  Repository _repository = Repository();
  final _assetsAudioPlayer = Repository().audioPlayer;
  StreamSubscription _audioEvents;
  StreamSubscription _audioFinished;
  StreamSubscription _percentageSS;

  MinimisedPlayerBloc() {
    _percentageSS = _repository.percentageStream.listen((event) {
      this.add(ButtonDownload(event.percent));
    });
    _audioEvents = _assetsAudioPlayer.playerState.listen((state) {
      if (state == PlayerState.play) this.add(ButtonAudioPlaying());
      if (state == PlayerState.pause) this.add(ButtonAudioPaused());
      if (state == PlayerState.stop) this.add(ButtonAudioStopped());
    });
    _audioFinished = _assetsAudioPlayer.playlistAudioFinished.listen((playing) {
      if (!playing.hasNext) this.add(ButtonAudioStopped());
    });
  }

  @override
  MinimisedPlayerState get initialState => ButtonNoAudio();

  @override
  Stream<MinimisedPlayerState> mapEventToState(MinimisedPlayerEvent event) async* {
    if (event is ButtonPlayPause) _assetsAudioPlayer.playOrPause();

    // React to Audio service event calls
    if (event is ButtonDownload) {
      yield ButtonIsDownloading(percentage: event.percentage);
    }
    if (event is ButtonAudioStopped) {
      yield ButtonNoAudio();
    }
    if (event is ButtonAudioPaused) {
        yield ButtonAudioIsPaused();
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
