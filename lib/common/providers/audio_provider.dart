import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:rxdart/rxdart.dart';

import '../repository/audio_repository.dart';

class AudioProvider {
  AudioProvider(this._audioPlayer) {
    _audioPlayer.playlistFinished.listen(_onAudioCompleted);
    _audioPlayer.playerState.listen(_onPlayerStateChange);
  }

  /// The audio player controlled by the provider.
  final AssetsAudioPlayer _audioPlayer;

  /// State of the audio player.
  final state = BehaviorSubject<AudioState>()
    ..defaultIfEmpty(AudioState.stopped);

  /// Emits values when audio has completed.
  final onAudioComplete = StreamController<int>();

  /// The current position of the player
  ValueStream<Duration> get audioPosition => _audioPlayer.currentPosition;

  /// The maximum duration of the current song.
  ///
  /// Defaults to the current audio position.
  Duration get maxDuration {
    if (_audioPlayer.current.value == null) {
      return audioPosition.value;
    } else {
      return _audioPlayer.current.value.audio.duration;
    }
  }

  /// Pauses the last emitted state was a playing one.
  Future<void> pause() {
    if (state.value == AudioState.playing) {
      return _audioPlayer.pause();
    } else {
      // To suppress returning null warnings.
      return Future.value();
    }
  }

  /// Plays a song if the last emitted state was a paused one.
  Future<void> play() {
    if (state.value == AudioState.paused) {
      return _audioPlayer.play();
    } else {
      // To suppress returning null warnings.
      return Future.value();
    }
  }

  /// Seeks to a given position within the audio.
  void seek(Duration position) {
    assert(position < maxDuration);
    _audioPlayer.seek(position);
  }

  Future<void> stop() {
    return _audioPlayer.stop();
  }

  void resetAudio() {
    _audioPlayer.seek(const Duration(), force: true);
  }

  /// Plays a give music file path.
  ///
  /// Returns true if playing the song was successful.
  /// [artwork] is used as an image within the notification shade.
  Future<bool> start({
    File songFile,
    File artwork,
    Metas metas,
    NotificationSettings notificationSettings,
  }) async {
    final isPlaying = Completer<bool>();
    final audio = Audio.file(songFile.path, metas: metas);
    try {
      await _audioPlayer.open(
        audio,
        showNotification: true,
        notificationSettings: notificationSettings,
      );
      if (artwork != null) {
        audio.updateMetas(image: MetasImage.file(artwork.path));
      }
      isPlaying.complete(true);
    } catch (e) {
      isPlaying.complete(false);
      rethrow;
    }
    return isPlaying.future;
  }

  /// When the current song has finished playing, go to next song or stop
  void _onAudioCompleted(bool isFinished) {
    if (_audioPlayer.current.value != null) {
      final currentPosition = _audioPlayer.currentPosition.value;
      final maxDuration = _audioPlayer.current.value.audio.duration;
      if (currentPosition >= maxDuration) {
        onAudioComplete.add(1);
      }
    }
  }

  void _onPlayerStateChange(PlayerState event) {
    switch(event) {
      case PlayerState.play:
        state.add(AudioState.playing);
        break;
      case PlayerState.pause:
        state.add(AudioState.paused);
        break;
      case PlayerState.stop:
        state.add(AudioState.stopped);
        break;
    }
  }

}
