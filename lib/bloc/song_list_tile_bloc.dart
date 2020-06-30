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

	SongListTileBloc({@required this.tileSong}) {
		assert(tileSong != null);

		onDownload = _repository.download.percentageStream.listen((event) {
			if (tileSong.id == event.songId && event.hasData) {
				this.add(SongListTileDownload(event.percentage));
			} else {
				this.add(SongListTileEmpty());
			}
		});
		onDownloadFinished = _repository.download.newPlayableSong.listen((event) {
			if (tileSong.id == event.id) this.add(SongListTileFinished());
		});
		onPlaying = _repository.audio.playerState.listen((state) {
			currentSong = _repository.audio.current;

			if (currentSong.id == tileSong.id) {
				if (state == AudioPlayerState.playing) {
					this.add(SongListTilePlaying(true));
				}

				if (state == AudioPlayerState.paused) {
					this.add(SongListTilePlaying(false));
				}

				if (state == AudioPlayerState.stopped) {
					this.add(SongListTileEmpty());
				}
			} else {
				this.add(SongListTileEmpty());
			}
		});
	}

	@override
	SongListTileState get initialState => SongListTileIsEmpty();

	@override
	Stream<SongListTileState> mapEventToState(SongListTileEvent event) async* {
		if (event is SongListTileEmpty) {
			yield SongListTileIsEmpty();
		}
		if (event is SongListTileDownload) {
			yield SongListTileIsDownloading(event.percentage);
		}
		if (event is SongListTileFinished) {
			yield SongListTileIsFinished();
			await Future.delayed(Duration(seconds: 2));
			yield SongListTileIsEmpty();
		}
		if (event is SongListTilePlaying) {
			if (event.isPlaying) {
				yield SongListTileIsPlaying();
			} else {
				yield SongListTileIsPaused();
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
