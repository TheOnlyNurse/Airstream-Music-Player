import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/audio_repository.dart';
import '../../../common/repository/image_repository.dart';

part 'player_events.dart';

part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc({
    this.albumRepository,
    this.imageRepository,
    AudioRepository audioRepository,
  })  : _audioRepository = audioRepository ?? GetIt.I.get<AudioRepository>(),
        super(PlayerInitial(audioRepository.current)) {
    _newSong = _audioRepository.songState.listen((state) => add(PlayerFetch()));
    _audioStopped = _audioRepository.audioState.listen((state) {
      if (state == AudioState.stopped) {
        add(PlayerStopped());
      }
    });
  }

  final AudioRepository _audioRepository;
  final AlbumRepository albumRepository;
  final ImageRepository imageRepository;

  StreamSubscription _newSong;
  StreamSubscription _audioStopped;

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    final currentState = state;

    if (event is PlayerFetch) {
      final song = _audioRepository.current;
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
      yield PlayerSuccess(song: _audioRepository.current, isFinished: true);
    }
  }

  @override
  Future<void> close() {
    _audioStopped.cancel();
    _newSong.cancel();
    return super.close();
  }
}
