import 'dart:async';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../providers/audio_provider.dart';
import '../providers/moor_database.dart';
import 'download_repository.dart';
import 'image_repository.dart';
import 'song_repository.dart';

enum AudioState { playing, paused, stopped }

class AudioRepository {
  AudioRepository({
    AudioProvider provider,
    SongRepository songRepository,
    DownloadRepository downloadRepository,
    ImageRepository imageRepository,
  })  : _provider =
            provider ?? AudioProvider(AssetsAudioPlayer.withId('airstream')),
        _songRepository = songRepository ?? GetIt.I.get<SongRepository>(),
        _downloadRepository =
            downloadRepository ?? GetIt.I.get<DownloadRepository>(),
        _imageRepository = imageRepository ?? GetIt.I.get<ImageRepository>() {
    _provider.onAudioComplete.stream.listen(_onAudioCompleted);
  }

  final AudioProvider _provider;
  final SongRepository _songRepository;
  final DownloadRepository _downloadRepository;
  final ImageRepository _imageRepository;

  /// Emits a new [Song] object when it's being played.
  final _songState = StreamController<Song>.broadcast();

  /// Queue of songs.
  final _songQueue = <Song>[];

  /// Current song index being attempted to be played.
  int _currentIndex = 0;

  ValueStream<Duration> get audioPosition => _provider.audioPosition;

  Duration get maxDuration => _provider.maxDuration;

  int get currentIndex => _currentIndex;

  int get queueLength => _songQueue.length;

  /// Returns a copy of the song queue.
  ///
  /// Changing the queue can only be done by methods within this repository.
  List<Song> get queue => List.from(_songQueue);

  /// Emits a new [Song] object when it's being played.
  Stream<Song> get songState => _songState.stream;

  /// Emits the current audio player state.
  ValueStream<AudioState> get audioState => _provider.state.stream;

  /// The current [song] object being attempted to be played.
  Song get current => _songQueue.isNotEmpty ? _songQueue[_currentIndex] : null;

  /// Returns whether the next index is possible.
  bool get hasNext => _currentIndex < _songQueue.length;

  /// Returns whether the previous index is possible.
  bool get hasPrevious {
    // Negative indexes should never be used.
    assert(!_currentIndex.isNegative);
    return _currentIndex != 0;
  }

  /// Start a new song queue and play the song at the specified index.
  Future<void> start({@required List<Song> songs, int index = 0}) async {
    // Reset the queue.
    _songQueue.clear();
    _songQueue.addAll(songs);
    return play(index);
  }

  /// Plays the song at the given index.
  ///
  /// Download the song if [filepath] within the song repository is null.
  /// Also fetches the playing song's artwork.
  Future<void> play(int index) async {
    assert(index >= 0 && index < _songQueue.length);
    _currentIndex = index;

    _songState.add(current);

    final artwork = await _imageRepository.highDefinition(current.art);
    (await _songRepository.file(current)).fold(
      // If file isn't cached, download it.
      (error) async {
        _provider.pause();
        (await _downloadRepository.download(current)).fold(
          // ignore: avoid_print
          (error) => print(error),
          (file) => _startAudio(file, artwork),
        );
      },
      (file) => _startAudio(file, artwork),
    );
  }

  void _startAudio(File file, Option<File> artwork) {
    _provider.start(
      songFile: file,
      artwork: artwork,
      metas: _toMetas(current),
      notificationSettings: NotificationSettings(
        customPrevAction: (player) => previous(),
        customNextAction: (player) => next(),
        customStopAction: (player) => _provider.stop(),
      ),
    );
  }

  /// Either plays or pauses the song depending on the current audio state.
  Future<void> playPause() {
    switch (audioState.value) {
      case AudioState.playing:
        return _provider.pause();
      case AudioState.paused:
        return _provider.play();
      default:
        throw Exception(
          'Play/pause failed. '
          'AudioState is ${audioState.value}.',
        );
    }
  }

  /// Plays the next song if one exists.
  void next() {
    if (hasNext) play(_currentIndex + 1);
  }

  /// Plays the previous song if one exists.
  ///
  /// Resets the audio position if the current position is greater than 5 seconds.
  void previous() {
    if (audioPosition.value > const Duration(seconds: 5)) {
      _provider.seek(const Duration());
    } else if (hasPrevious) {
      play(_currentIndex - 1);
    }
  }

  /// Seeks to a position within indicated.
  void seek(double seconds) {
    _provider.seek(Duration(seconds: seconds.floor()));
  }

  /// Moves a song from the [from] index to the [to] index in the current song queue.
  void reorder(int from, int to) {
    // Removing the item at oldIndex will shorten the list by 1.
    // Therefore, a new potentially adjusted variable is used.
    final _to = from < to ? to - 1 : to;

    // Adjust the current index to properly align with new list order.
    // If the from index is the same as the playing song's, just use the to index.
    if (from == _currentIndex) {
      _currentIndex = _to;
    }
    // If the reorder moves a song in front the playing song's.
    else if (from < _currentIndex && _to >= _currentIndex) {
      _currentIndex--;
    }
    // If the reorder moves a song behind the playing song's.
    else if (_to <= _currentIndex && from > _currentIndex) {
      _currentIndex++;
    }

    // With all the indexes corrected, change the list.
    final songRemoved = _songQueue.removeAt(from);
    _songQueue.insert(_to, songRemoved);
  }

  /// When the current song has finished playing, go to next song or stop
  void _onAudioCompleted(_) {
    hasNext ? play(_currentIndex++) : _provider.stop();
  }

  /// Converts song details into assets' metas file
  Metas _toMetas(Song song) {
    return Metas(
      title: song.title,
      artist: song.artist,
      album: song.album,
    );
  }
}
