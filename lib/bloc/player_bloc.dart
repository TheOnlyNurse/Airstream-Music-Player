import 'dart:async';
import 'dart:io';

import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/models/song_model.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:bloc/bloc.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  StreamSubscription _newSongSS;
  StreamSubscription _audioStopped;
  Song currentSong = Repository().audio.current;

  PlayerBloc() {
    final player = Repository().audio.audioPlayer;
    _newSongSS = player.current.listen((playing) {
      if (currentSong != Repository().audio.current) {
        currentSong = Repository().audio.current;
        this.add(PlayerEvent.fetchAlbum);
      }
    });
    _audioStopped = player.playerState.listen((state) {
      if (state == assets.PlayerState.stop) {
        this.add(PlayerEvent.complete);
      }
    });
  }

  @override
  PlayerState get initialState => PlayerInitial(currentSong);

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
		final currentState = state;

		if (event == PlayerEvent.fetchAlbum) {
			final albumResponse = await Repository().album.fromSong(currentSong);

			if (albumResponse.status == DataStatus.ok) {
				yield PlayerSuccess(song: currentSong, album: albumResponse.data.first);
				this.add(PlayerEvent.fetchArt);
			}
		}

		if (currentState is PlayerSuccess) {
			if (event == PlayerEvent.fetchArt) {
				final artResponse =
				await Repository().image.fromArt(currentSong.art, isHiDef: true);

				if (artResponse.status == DataStatus.ok) {
					yield currentState.copyWith(image: artResponse.data);
				}
			}
			if (event == PlayerEvent.complete) {
				yield currentState.copyWith(isFinished: true);
			}
    }
  }

  @override
  Future<void> close() {
		_audioStopped.cancel();
		_newSongSS.cancel();
		return super.close();
	}
}

enum PlayerEvent { fetchAlbum, fetchArt, complete }

abstract class PlayerState {}

class PlayerInitial extends PlayerState {
  final Song song;

  PlayerInitial(this.song);
}

class PlayerSuccess extends PlayerState {
	final Song song;
	final Album album;
	final File image;
	final bool isFinished;

	PlayerSuccess({this.song, this.image, this.album, this.isFinished = false});

	PlayerSuccess copyWith({Album album, File image, bool isFinished}) =>
			PlayerSuccess(
				song: this.song,
				album: album ?? this.album,
				image: image ?? this.image,
				isFinished: isFinished ?? false,
			);
}

class PlayerFailure extends PlayerState {}
