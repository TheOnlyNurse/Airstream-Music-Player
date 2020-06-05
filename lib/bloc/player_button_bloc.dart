import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/player_button_event.dart';
import 'package:airstream/models/song_model.dart';
import 'package:airstream/states/player_button_state.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerButtonBloc extends Bloc<PlayerButtonEvent, PlayerButtonState> {
  List<Song> playlist;
  int currentIndex;
  Repository _repository = Repository();
  final _assetsAudioPlayer = AssetsAudioPlayer.withId('airstream');
  StreamSubscription _audioEvents;
  StreamSubscription _audioFinished;
  StreamSubscription _percentageSS;

  PlayerButtonBloc() {
    _percentageSS = _repository.percentageStream.listen((event) {
      this.add(DownloadEvent(event.percent));
    });
    _audioEvents = _assetsAudioPlayer.isPlaying.listen((isPlaying) {
      if (isPlaying)
        this.add(SongIsPlaying());
      else
        this.add(SongIsPaused());
    });
    _audioFinished = _assetsAudioPlayer.playlistAudioFinished.listen((playing) {
      if (!playing.hasNext) this.add(SongHasStopped());
    });
  }

  @override
  PlayerButtonState get initialState => NoMusic();

  @override
  Stream<PlayerButtonState> mapEventToState(PlayerButtonEvent event) async* {
    if (event is PauseSong) _assetsAudioPlayer.pause();
    if (event is ResumeSong) _assetsAudioPlayer.play();

    // React to Audio service event calls
    if (event is DownloadEvent) {
      yield DownloadingMusic(percentage: event.percent);
    }
    if (event is SongHasStopped) {
      yield NoMusic();
    }
    if (event is SongIsPaused) {
      yield MusicPaused();
    }
    if (event is SongIsPlaying) {
      yield MusicPlaying();
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
