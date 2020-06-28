import 'package:airstream/barrel/provider_basics.dart';
import 'package:path/path.dart' as p;
import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:path_provider/path_provider.dart';
import 'dart:math' as Math;

class AudioProvider {
  /// Global Variables
  final StreamController<PercentageModel> percentageSC = StreamController.broadcast();
  final List<Song> songQueue = <Song>[];
  int currentSongIndex = 0;
  bool downloadIsIdling = true;

  assets.AssetsAudioPlayer get audioPlayer =>
      assets.AssetsAudioPlayer.withId('airstream');

  Song get currentSong => songQueue[currentSongIndex];

  /// Private Variables
  StreamSubscription _downloadSS;
  IOSink _tempSongSink;


  bool get _hasNext => currentSongIndex + 1 < songQueue.length;

  /// Global Functions
  void createQueueAndPlay(List<Song> playlist, int index) {
    this.songQueue.clear();
    this.songQueue.addAll(playlist);
    this.currentSongIndex = index;
    this._checkForPath();
  }

  void skipTo(int skipBy) async {
    if (audioPlayer.currentPosition.value > Duration(seconds: 5) && skipBy == -1) {
      audioPlayer.seek(Duration(seconds: 0), force: true);
    } else if (currentSongIndex + skipBy + 1 > songQueue.length ||
        currentSongIndex + skipBy < 0) {
      return;
    } else {
      this.currentSongIndex += skipBy;
      this._checkForPath();
    }
  }

  /// Private Functions
  /// Functions/streams listened to when initialised
  void _onStart() {
    audioPlayer.playlistFinished.listen((isFinished) {
      if (audioPlayer.current.value != null) {
        final isAtEnd = audioPlayer.currentPosition.value >=
            audioPlayer.current.value.audio.duration - Duration(seconds: 2);
        if (isAtEnd) {
          if (_hasNext) {
            currentSongIndex++;
            _checkForPath();
          } else {
            audioPlayer.seek(Duration(seconds: 0));
            audioPlayer.pause();
          }
        }
      }
    });
  }

  /// Download Song, place into cache and prompt play
  Future<Null> _downloadSong(Song song, {bool isNotPrefetch = true}) async {
    final _completer = Completer<Null>();
    downloadIsIdling = false;
    final tempFile = File(p.join((await getTemporaryDirectory()).path, 'song_file'));
    if (tempFile.existsSync()) tempFile.deleteSync();
    _tempSongSink = tempFile.openWrite(mode: FileMode.append);

    final StreamController<List<int>> fileBytesSC = StreamController();
    if (isNotPrefetch) percentageSC.add(PercentageModel(current: 0, total: 1));
    final totalFileSize =
        await ServerProvider().streamFile('stream?id=${song.id}', fileBytesSC);
    int currentFileSize = 0;

    _downloadSS = fileBytesSC.stream.listen((bytes) {
      _tempSongSink.add(bytes);
      if (isNotPrefetch) {
        currentFileSize += bytes.length;
        percentageSC.add(PercentageModel(
          current: currentFileSize,
          total: totalFileSize,
        ));
      }
    });
    _downloadSS.onDone(() async {
      _tempSongSink.close();
      _downloadSS.cancel();
      _downloadSS = null;
      final songPath = await AudioCacheProvider().cacheFile(
        tempFile,
        songId: song.id,
        artistName: song.artist,
        albumId: song.albumId,
      );
      _completer.complete();
      downloadIsIdling = true;
      if (isNotPrefetch) this._play(songPath, song);
    });
    return _completer.future;
  }

  void _prefetch() async {
    final int songsToFetch = Math.min(
      await SettingsProvider().prefetchValue,
      this.songQueue.length - this.currentSongIndex - 1,
    );
    int songsFetched = 0;
    while (songsToFetch - songsFetched > 0 && downloadIsIdling) {
			final song = songQueue[currentSongIndex + songsFetched + 1];
      final songPath = await AudioCacheProvider().getSongLocation(song.id);
      if (songPath == null) await _downloadSong(song, isNotPrefetch: false);
      await Repository().image.fromArt(song.art);
      songsFetched += 1;
    }
  }

  void _updateCoverArt(assets.Audio audio, Song song) async {
		final artResp = await Repository().image.fromArt(song.art);
		if (artResp.status == DataStatus.ok) {
			audio.updateMetas(image: assets.MetasImage.file(artResp.data.path));
		}
	}

	void _play(String songPath, Song song) async {
		final audio = assets.Audio.file(songPath, metas: song.toMetas());
		try {
			await audioPlayer.open(
				audio,
				showNotification: true,
				notificationSettings: assets.NotificationSettings(
					customPrevAction: (player) => this.skipTo(-1),
					customNextAction: (player) => this.skipTo(1),
				),
			);
      _updateCoverArt(audio, song);
      _prefetch();
    } catch (e) {
      if (audioPlayer.current.value != null) audioPlayer.stop();
      AudioCacheProvider().deleteSongFile(song.id);
    }
  }

	void _checkForPath() async {
		// Cancel any existing downloads in favour of the new song
		if (_downloadSS != null) _downloadSS.cancel();

		final song = this.currentSong;
		final songPath = await AudioCacheProvider().getSongLocation(song.id);
		if (songPath != null) {
			this._play(songPath, song);
		} else {
			if (audioPlayer.current.value != null) audioPlayer.pause();
			_downloadSong(song);
		}
	}

	/// Singleton boilerplate code
	static final AudioProvider _instance = AudioProvider._internal();

	AudioProvider._internal() {
		_onStart();
	}

	factory AudioProvider() => _instance;
}
