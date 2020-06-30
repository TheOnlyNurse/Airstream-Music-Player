import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/barrel/provider_basics.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:rxdart/rxdart.dart';
import 'moor_database.dart';

class AudioProvider {
  /// Globally Accessible

  /// The currently playing/to be played song's index within the queue
  int get currentIndex => _currentIndex;

  /// A copy of the songQueue
  List<Song> get songQueue => List.from(_songQueue);

  /// The current Song (class containing details) being played
  Song get currentSong => _songQueue[_currentIndex];

  /// A stream of player states
  ValueStream<AudioPlayerState> get playerState => _playerState.stream;

  /// A stream of song states (newSong)
  Stream<AudioPlayerSongState> get songState => _songState.stream;

  /// The current position of the player
  ValueStream<Duration> get audioPosition => _audioPlayer.currentPosition;

  /// The maximum duration of the current song
  ///
  /// Defaults to the current audio position
  Duration get maxDuration {
    if (_audioPlayer.current.value == null) return audioPosition.value;
    return _audioPlayer.current.value.audio.duration;
  }

  /// Global Functions
  void createQueueAndPlay(List<Song> playlist, int index) {
    if (playlist != _songQueue) {
      this._songQueue.clear();
      this._songQueue.addAll(playlist);
    }
    this._currentIndex = index;
    this._playCurrent();
  }

  void changePlayerState(ChangePlayerState state) {
    if (_audioPlayer.current.value == null) return;

    switch (state) {
      case ChangePlayerState.stop:
        _audioPlayer.stop();
        _playerState.add(AudioPlayerState.stopped);
        break;
      case ChangePlayerState.play:
        _audioPlayer.play();
        _playerState.add(AudioPlayerState.playing);
        break;
      case ChangePlayerState.pause:
        _audioPlayer.pause();
        _playerState.add(AudioPlayerState.paused);
        break;
      case ChangePlayerState.next:
        if (_currentIndex + 1 < _songQueue.length) {
          this._currentIndex++;
          this._playCurrent();
        }
        break;
      case ChangePlayerState.previous:
        if (_audioPlayer.currentPosition.value > Duration(seconds: 5)) {
          _audioPlayer.seek(Duration(seconds: 0), force: true);
        } else {
          this._currentIndex--;
          this._playCurrent();
        }
        break;
    }
  }

  void seekPosition(Duration position) {
    if (position > maxDuration) return;
    _audioPlayer.seek(position);
  }

  /// Private
  ///
  /// State (play, paused, stopped) of the audio player
  final _playerState = BehaviorSubject<AudioPlayerState>();
  final _songState = StreamController<AudioPlayerSongState>.broadcast();
  final _audioPlayer = assets.AssetsAudioPlayer.withId('airstream');
  final List<Song> _songQueue = <Song>[];
  var _currentIndex = 0;

  /// Open the given path and song with the audio player
  void _play(String songPath, Song song) async {
    final audio = assets.Audio.file(songPath, metas: toMetas(song));
    final notificationSettings = assets.NotificationSettings(
      customPrevAction: (player) {
        this.changePlayerState(ChangePlayerState.previous);
      },
      customNextAction: (player) =>
          this.changePlayerState(ChangePlayerState.next),
      customStopAction: (player) =>
          this.changePlayerState(ChangePlayerState.stop),
    );

    try {
      await _audioPlayer.open(
        audio,
        showNotification: true,
        notificationSettings: notificationSettings,
      );
      // Update the art, once the song has started playing
      final art = await Repository().image.lowDef(song.art);
      if (art != null) {
        audio.updateMetas(
          image: assets.MetasImage.file(art.path),
        );
      }
      // Prefetch
      DownloadProvider().prefetch();
      _playerState.add(AudioPlayerState.playing);
    } catch (e) {
      changePlayerState(ChangePlayerState.stop);
      await Repository().audioCache.deleteSong(song);
    }
  }

  /// Converts song details into assets' metas file
  assets.Metas toMetas(Song song) {
    return assets.Metas(
      title: song.title,
      artist: song.artist,
      album: song.album,
    );
  }

  /// Prepare the current song to be played
  void _playCurrent() async {
    final song = this.currentSong;
    // Notify new song is loading
    _songState.add(AudioPlayerSongState.newSong);
    final response = await Repository().audioCache.pathOf(song);
    if (response.hasData) {
      this._play(response.path, song);
    } else {
      if (_audioPlayer.current.value != null) _audioPlayer.pause();
      DownloadProvider().downloadSong(song);
    }
  }

  /// When the current song has finished playing, go to next song or stop
  void _whenAudioFinished(bool isFinished) {
    if (_audioPlayer.current.value != null) {
      final currentPosition = _audioPlayer.currentPosition.value;
      final maxDuration =
          _audioPlayer.current.value.audio.duration - Duration(seconds: 2);
      final hasNext = _currentIndex + 1 < _songQueue.length - 1;
      if (currentPosition >= maxDuration) {
        if (hasNext) {
          changePlayerState(ChangePlayerState.next);
        } else {
          changePlayerState(ChangePlayerState.stop);
        }
      }
    }
  }

  /// If the newly downloaded song is the current required song, play it
  void _whenSongIsPlayable(song) {
    if (song == currentSong) _playCurrent();
  }

  /// Singleton boilerplate code
  static final AudioProvider _instance = AudioProvider._internal();

  AudioProvider._internal() {
    _audioPlayer.playlistFinished.listen(_whenAudioFinished);
    DownloadProvider().songPlayable.listen(_whenSongIsPlayable);
  }

  factory AudioProvider() => _instance;
}

enum ChangePlayerState { stop, play, pause, next, previous }
