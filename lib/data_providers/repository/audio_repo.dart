import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/models/percentage_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:airstream/data_providers/audio_provider.dart';

class AudioRepository {
  final _provider = AudioProvider();

  Stream<PercentageModel> get percentageStream => AudioProvider().percentageSC.stream;

  int get index => AudioProvider().currentSongIndex;

  Song get current => AudioProvider().currentSong;

  int get playlistLength => AudioProvider().songQueue.length;

  List<Song> get queue {
    final queue = <Song>[];
    queue.addAll(_provider.songQueue);
    return queue;
  }

  assets.AssetsAudioPlayer get audioPlayer => AudioProvider().audioPlayer;

  void skipToNext() => AudioProvider().skipTo(1);

  void skipToPrevious() => AudioProvider().skipTo(-1);

  void play({@required List<Song> playlist, int index = 0}) =>
      AudioProvider().createQueueAndPlay(playlist, index);
}