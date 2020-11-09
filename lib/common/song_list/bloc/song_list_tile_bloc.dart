import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../providers/moor_database.dart';
import '../../repository/communication.dart';
import '../../repository/repository.dart';
import '../../repository/song_repository.dart';

part 'song_list_tile_event.dart';
part 'song_list_tile_state.dart';

class SongListTileBloc extends Bloc<SongListTileEvent, SongListTileState> {
  final Song tileSong;
  final _repository = Repository();
  Song currentSong;
  StreamSubscription onDownload;
  StreamSubscription onDownloadFinished;
  StreamSubscription onPlaying;

  SongListTileBloc({@required this.tileSong})
      : assert(tileSong != null),
        super(SongListTileInitial()) {
    onDownload = _repository.download.percentageStream.listen((event) {
      if (tileSong.id == event.songId && event.hasData) {
        add(SongListTileDownload(event.percentage));
      }
    });
    onDownloadFinished = _repository.download.newPlayableSong.listen((event) {
      if (tileSong.id == event.id) add(SongListTileFinished());
    });
    onPlaying = _repository.audio.playerState.listen((state) {
      currentSong = _repository.audio.current;
      if (currentSong.id == tileSong.id && state == AudioPlayerState.playing) {
        add(const SongListTilePlaying(isPlaying: true));
      } else {
        add(const SongListTilePlaying(isPlaying: false));
      }
    });
  }

  @override
  Stream<SongListTileState> mapEventToState(SongListTileEvent event) async* {
    final currentState = state;
    if (event is SongListTileFetch) {
      final response = await GetIt.I.get<SongRepository>().filePath(tileSong);
      if (response != null) {
        yield const SongListTileSuccess(cachePercent: 100);
      } else {
        yield const SongListTileSuccess();
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
