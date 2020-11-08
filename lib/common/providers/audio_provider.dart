import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../repository/communication.dart';
import '../repository/image_repository.dart';
import '../repository/song_repository.dart';
import 'download_provider.dart';
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
      _songQueue.clear();
      _songQueue.addAll(playlist);
    }
    playFromQueue(index);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    int adjustedIndex = newIndex;
    if (oldIndex < newIndex) {
      // removing the item at oldIndex will shorten the list by 1.
      adjustedIndex--;
    }
    // Adjust the current index to properly align with new list order
    if (oldIndex == _currentIndex) {
      _currentIndex = adjustedIndex;
    } else if (oldIndex < _currentIndex && adjustedIndex >= _currentIndex) {
      _currentIndex--;
    } else if (adjustedIndex <= _currentIndex && oldIndex > _currentIndex) {
      _currentIndex++;
    }
    final element = _songQueue.removeAt(oldIndex);
    _songQueue.insert(adjustedIndex, element);
  }

  void playFromQueue(int index) {
    _currentIndex = index;
    _playCurrent();
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
          _currentIndex++;
          _playCurrent();
        }
        break;
      case ChangePlayerState.previous:
        if (_audioPlayer.currentPosition.value > const Duration(seconds: 5)) {
          _audioPlayer.seek(const Duration(), force: true);
        } else {
          _currentIndex--;
          _playCurrent();
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
  Future<void> _play(String songPath, Song song) async {
    final audio = assets.Audio.file(songPath, metas: _toMetas(song));
    final notificationSettings = assets.NotificationSettings(
      customPrevAction: (player) {
        changePlayerState(ChangePlayerState.previous);
      },
      customNextAction: (player) => changePlayerState(ChangePlayerState.next),
      customStopAction: (player) => changePlayerState(ChangePlayerState.stop),
    );

    try {
      await _audioPlayer.open(
        audio,
        showNotification: true,
        notificationSettings: notificationSettings,
      );
      // Update the art, once the song has started playing
      final art = await GetIt.I.get<ImageRepository>().highDefinition(song.art);
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
      await GetIt.I.get<SongRepository>().deleteFile(song);
    }
  }

  /// Converts song details into assets' metas file
  assets.Metas _toMetas(Song song) {
    return assets.Metas(
      title: song.title,
      artist: song.artist,
      album: song.album,
    );
  }

  /// Prepare the current song to be played
  Future<void> _playCurrent() async {
    final song = currentSong;
    // Notify new song is loading
    _songState.add(AudioPlayerSongState.newSong);
    final filePath = await GetIt.I.get<SongRepository>().filePath(song);
    if (filePath != null) {
      _play(filePath, song);
    } else {
      if (_audioPlayer.current.value != null) _audioPlayer.pause();
      DownloadProvider().downloadSong(song);
    }
  }

  /// When the current song has finished playing, go to next song or stop
  void _whenAudioFinished(bool isFinished) {
    if (_audioPlayer.current.value != null) {
      final currentPosition = _audioPlayer.currentPosition.value;
      final maxDuration = _audioPlayer.current.value.audio.duration -
          const Duration(seconds: 2);
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
  factory AudioProvider() => _instance;
  static final AudioProvider _instance = AudioProvider._internal();

  AudioProvider._internal() {
    _audioPlayer.playlistFinished.listen(_whenAudioFinished);
    DownloadProvider().songPlayable.listen(_whenSongIsPlayable);
  }
}

enum ChangePlayerState { stop, play, pause, next, previous }
