import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../providers/moor_database.dart';
import '../../repository/audio_repository.dart';
import '../../repository/download_repository.dart';
import '../../repository/song_repository.dart';

part 'song_list_tile_event.dart';

part 'song_list_tile_state.dart';

class SongListTileBloc extends Bloc<SongListTileEvent, SongListTileState> {
  SongListTileBloc({
    @required this.tileSong,
    AudioRepository audioRepository,
    DownloadRepository downloadRepository,
  })  : assert(tileSong != null),
  _audioRepository = audioRepository ?? GetIt.I.get<AudioRepository>(),
  _downloadRepository = downloadRepository ?? GetIt.I.get<DownloadRepository>(),
        super(SongListTileInitial()) {
    onDownload = _downloadRepository.percentage.listen((event) {
      if (tileSong.id == event.songId && event.isActive) {
        if (event.percentage < 96) {
          add(SongListTileDownload(event.percentage));
        } else {
          // TODO: Clean up this download finished behaviour.
          add(SongListTileFinished());
        }
      }
    });
    onPlaying = _audioRepository.audioState.listen((state) {
      if (state == AudioState.playing) {
        currentSong = audioRepository.current;
        if (currentSong.id == tileSong.id) {
          add(const SongListTilePlaying(isPlaying: true));
        } else {
          add(const SongListTilePlaying(isPlaying: false));
        }
      } else {
        add(const SongListTilePlaying(isPlaying: false));
      }
    });
  }

  final Song tileSong;
  final AudioRepository _audioRepository;
  final DownloadRepository _downloadRepository;
  Song currentSong;
  StreamSubscription onDownload;
  StreamSubscription onDownloadFinished;
  StreamSubscription onPlaying;

  @override
  Stream<SongListTileState> mapEventToState(SongListTileEvent event) async* {
    final currentState = state;
    if (event is SongListTileFetch) {
      final response = await GetIt.I.get<SongRepository>().file(tileSong);
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
