import 'dart:async';
import 'dart:io';

import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:bloc/bloc.dart';

enum PlayerEvent { fetch }

abstract class PlayerState {}

class PlayerInitial extends PlayerState {
  final Song song;

  PlayerInitial(this.song);
}

class PlayerSuccess extends PlayerState {
  final Song song;
  final Album album;
  final File image;

  PlayerSuccess(this.song, {this.image, this.album});
}

class PlayerFailure extends PlayerState {}

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  StreamSubscription _audioSS;
  Song currentSong = Repository().currentSong;

  PlayerBloc() {
    _audioSS = Repository().audioPlayer.current.listen((playing) {
      if (currentSong != Repository().currentSong) {
        currentSong = Repository().currentSong;
        this.add(PlayerEvent.fetch);
      }
    });
  }

  @override
  PlayerState get initialState => PlayerInitial(currentSong);

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    /// First fetches the current song information, then album and finally image information
    if (event == PlayerEvent.fetch) {
      yield PlayerInitial(currentSong);
      Album album;

      final albumResponse = await Repository().getAlbumFromSong(currentSong);
      if (albumResponse.status == DataStatus.ok) album = albumResponse.data;
      yield PlayerSuccess(currentSong, album: album);

      final response = await Repository().getImage(artId: currentSong.art);
      if (response.status == DataStatus.ok)
        yield PlayerSuccess(currentSong, album: album, image: response.data);
    }
  }

  @override
  Future<void> close() {
    _audioSS.cancel();
    return super.close();
  }
}
