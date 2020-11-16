import 'dart:async';

import 'package:airstream/common/global_assets.dart';
import 'package:airstream/common/models/download_percentage.dart';
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
        _audioRepository = getIt<AudioRepository>(audioRepository),
        _downloadRepository = getIt<DownloadRepository>(downloadRepository),
        super(const SongListTileState()) {
    onDownload = _downloadRepository.percentage.listen((event) {
      _onDownload(event, this);
    });
    onPlaying = _audioRepository.audioState.listen((state) {
      _onAudio(state, _audioRepository.current, this);
    });
  }

  final Song tileSong;
  final AudioRepository _audioRepository;
  final DownloadRepository _downloadRepository;
  Song currentSong;
  StreamSubscription onDownload;
  StreamSubscription onPlaying;

  @override
  Stream<SongListTileState> mapEventToState(SongListTileEvent event) async* {
    if (event is SongListTileFetch) {
      final response = await GetIt.I.get<SongRepository>().file(tileSong);
      if (response == null) yield state.copyWith(cachePercent: 0);
    }

    if (event is SongListTileDownload) {
      yield state.copyWith(cachePercent: event.percentage);
    }

    if (event is SongListTilePlaying) {
      yield state.copyWith(isPlaying: event.isPlaying);
    }
  }

  @override
  Future<void> close() {
    onPlaying.cancel();
    onDownload.cancel();
    return super.close();
  }
}

void _onDownload(DownloadPercentage event, SongListTileBloc bloc) {
  if (bloc.tileSong.id == event.songId && event.isActive) {
    if (event.isNotCached) bloc.add(SongListTileDownload(event.percentage));
  }
}

void _onAudio(AudioState state, Song current, SongListTileBloc bloc) {
  if (state == AudioState.playing) {
    if (current.id == bloc.tileSong.id) {
      bloc.add(const SongListTilePlaying(isPlaying: true));
    } else {
      bloc.add(const SongListTilePlaying(isPlaying: false));
    }
  } else {
    bloc.add(const SongListTilePlaying(isPlaying: false));
  }
}
