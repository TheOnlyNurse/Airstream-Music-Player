import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/events/song_list_tile_event.dart';
import 'package:airstream/states/song_list_tile_state.dart';
import 'package:airstream/barrel/bloc_basics.dart';
import 'package:flutter/foundation.dart';

class SongListTileBloc extends Bloc<SongListTileEvent, SongListTileState> {
  final Song tileSong;
  final _repository = Repository();
  Song currentSong;
  StreamSubscription onDownload;
  StreamSubscription onDownloadFinished;
  StreamSubscription onPlaying;

  SongListTileBloc({@required this.tileSong}) : super(SongListTileInitial()) {
    assert(tileSong != null);

    onDownload = _repository.download.percentageStream.listen((event) {
      if (tileSong.id == event.songId && event.hasData) {
        this.add(SongListTileDownload(event.percentage));
      }
    });
    onDownloadFinished = _repository.download.newPlayableSong.listen((event) {
      if (tileSong.id == event.id) this.add(SongListTileFinished());
    });
    onPlaying = _repository.audio.playerState.listen((state) {
      currentSong = _repository.audio.current;
      if (currentSong.id == tileSong.id && state == AudioPlayerState.playing) {
        this.add(SongListTilePlaying(true));
      } else {
        this.add(SongListTilePlaying(false));
      }
    });
  }

  @override
  Stream<SongListTileState> mapEventToState(SongListTileEvent event) async* {
    final currentState = state;
    if (event is SongListTileFetch) {
      final response = await _repository.audioCache.pathOf(tileSong);
      if (response.hasData) {
        yield SongListTileSuccess(cachePercent: 100);
      } else {
        yield SongListTileSuccess(cachePercent: 0);
      }
    }

    if (currentState is SongListTileSuccess) {
      if (event is SongListTileDownload) {
        yield currentState.copyWith(cachePercent: event.percentage);
      }
      if (event is SongListTileFinished) {
        yield currentState.copyWith(cachePercent: 100);
      }
      if (event is SongListTilePlaying) {
        yield currentState.copyWith(isPlaying: event.isPlaying);
      }
    }
  }

  @override
  Future<void> close() {
    onPlaying.cancel();
    onDownload.cancel();
    onDownloadFinished.cancel();
    return super.close();
  }
}
