import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/barrel/provider_basics.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:path/path.dart' as p;
import 'dart:math' as Math;
import 'package:path_provider/path_provider.dart';
import 'moor_database.dart';

class DownloadProvider {
  /// Global functions
  Stream<PercentageModel> get percentageStream => _percentage.stream;

  Stream<Song> get songPlayable => _songPlayable.stream;

  /// Private variables
  final _percentage = StreamController<PercentageModel>.broadcast();
  final _songPlayable = StreamController<Song>.broadcast();
  Timer _timeoutTimer;
  StreamSubscription<List<int>> _downloadSS;
  IOSink _tempSongSink;

  Future<File> get _tempFile async {
    return File(p.join((await getTemporaryDirectory()).path, 'song_file'));
  }

  /// Download Song, place into cache and prompt play
  Future<Null> downloadSong(Song song) async {
    await _prepareNewDownload(song);
    final whenComplete = Completer<Null>();
    final fileBytes = StreamController<List<int>>();
    final response = await ServerProvider().streamFile(
      'stream?id=${song.id}',
      fileBytes,
    );

    var current = PercentageModel(hasData: true, songId: song.id);

    if (response.hasData) {
      current = current.update(total: response.contentSize);

      _downloadSS = fileBytes.stream.listen((bytes) {
        _startTimer(whenComplete, current);
        _tempSongSink.add(bytes);
        // Update the current percentage
        current = current.update(addToCurrent: bytes.length);
        _percentage.add(current);
      });

      _downloadSS.onDone(() async {
				_closeSinks();
        await Repository().audioCache.cache(await _tempFile, song);
        _songPlayable.add(song);
        whenComplete.complete();
      });
      return whenComplete.future;
    } else {
      _percentage.add(current.update(hasData: false));
      return null;
    }
  }

  void prefetch() async {
    final provider = AudioProvider();
    final currentIndex = provider.currentIndex;
    final initialSong = provider.currentSong;
    final initialQueue = provider.songQueue;

    final maxNextSongs = provider.songQueue.length - currentIndex - 1;
    final int prefetch = SettingsProvider().query(SettingType.prefetch);
    final songsToFetch = Math.min(prefetch, maxNextSongs);

    for (var index = currentIndex + 1;
    index < currentIndex + songsToFetch + 1;
    index++) {
			if (provider.currentSong.id != initialSong.id) break;
      if (provider.songQueue.length != initialQueue.length) break;

      final song = initialQueue[index];
      final songPath = await Repository().audioCache.pathOf(song);
      if (songPath.hasNoData) await downloadSong(song);
      await Repository().image.thumbnail(song.art);
    }
  }

  /// Private Functions
  void _closeSinks() {
    _cancelTimer();
    _downloadSS.cancel();
    _downloadSS = null;
    _tempSongSink.close();
  }

  void _cancelTimer() {
    if (_timeoutTimer != null) {
      _timeoutTimer.cancel();
      _timeoutTimer = null;
    }
  }

  void _startTimer(Completer downloadComplete, PercentageModel percentage) {
    _cancelTimer();
    _timeoutTimer = Timer(Duration(seconds: 5), () {
      _closeSinks();
      _percentage.add(percentage.update(hasData: false));
      downloadComplete.complete();
    });
  }

  Future<Null> _prepareNewDownload(Song song) async {
    // Cancel any existing downloads in favour of the new song
    if (_downloadSS != null) _closeSinks();

    final tempFile = await _tempFile;
    if (tempFile.existsSync()) tempFile.deleteSync();
    _tempSongSink = tempFile.openWrite(mode: FileMode.append);
    _percentage.add(PercentageModel(hasData: true, songId: song.id));
    return;
  }

  /// Singleton boilerplate
  DownloadProvider._internal();

  static final DownloadProvider _instance = DownloadProvider._internal();

  factory DownloadProvider() => _instance;
}
