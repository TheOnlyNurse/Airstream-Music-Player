import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/communication.dart';
import '../../../common/repository/image_repository.dart';
import '../../../common/repository/repository.dart';

part 'player_events.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final _repository = Repository();
  final AlbumRepository albumRepository;
  final ImageRepository imageRepository;

  StreamSubscription _newSong;
  StreamSubscription _audioStopped;

  PlayerBloc({this.albumRepository, this.imageRepository})
      : super(PlayerInitial(Repository().audio.current)) {
    _newSong = _repository.audio.songState.listen((state) {
      if (state == AudioPlayerSongState.newSong) {
        add(PlayerFetch());
      }
    });
    _audioStopped = _repository.audio.playerState.listen((state) {
      if (state == AudioPlayerState.stopped) {
        add(PlayerStopped());
      }
    });
  }

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    final currentState = state;

    if (event is PlayerFetch) {
      final song = _repository.audio.current;
      final response = await albumRepository.byId(song.albumId);
      if (response.hasData) {
        yield PlayerSuccess(song: song, album: response.data);
        add(PlayerFetchArt(song.art));
      }
    }

    if (event is PlayerFetchArt) {
      final response = await imageRepository.highDefinition(event.artId);
      if (response != null && currentState is PlayerSuccess) {
        yield currentState.copyWith(image: response);
      }
    }

    if (event is PlayerStopped) {
      yield PlayerSuccess(song: _repository.audio.current, isFinished: true);
    }
  }

  @override
  Future<void> close() {
    _audioStopped.cancel();
    _newSong.cancel();
    return super.close();
  }
}
