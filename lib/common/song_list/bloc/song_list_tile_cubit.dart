import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../global_assets.dart';
import '../../providers/moor_database.dart';
import '../../repository/audio_repository.dart';
import '../../repository/download_repository.dart';
import '../../repository/song_repository.dart';
import '../../selection_bar/bloc/selection_bar_cubit.dart';

part 'song_list_tile_event.dart';

part 'song_list_tile_state.dart';

class SongListTileCubit extends Cubit<SongListTileState> {
  SongListTileCubit({
    @required this.song,
    @required this.selectionBarCubit,
    AudioRepository audio,
    DownloadRepository download,
  })  : assert(song != null),
        _audio = getIt<AudioRepository>(audio),
        _download = getIt<DownloadRepository>(download),
        super(const SongListTileState()) {
    _onInit();
  }

  final Song song;
  final SelectionBarCubit selectionBarCubit;
  final AudioRepository _audio;
  final DownloadRepository _download;
  StreamSubscription onDownload;
  StreamSubscription onPlaying;
  StreamSubscription onSelection;

  Future<void> checkCache() async {
    final response = await GetIt.I.get<SongRepository>().file(song);
    if (response == null) emit(state.copyWith(cachePercent: 0));
  }

  void onLongPress() => selectionBarCubit.selected(song);

  void _onInit() {
    // When the song represented by the tile is being downloaded.
    onDownload = _download.percentage.listen((event) {
      if (song.id == event.songId && event.isActive) {
        if (event.isNotCached) {
          emit(state.copyWith(cachePercent: event.percentage));
        }
      }
    });
    // When audio state changes update this tile to match.
    onPlaying = _audio.audioState.listen((audioState) {
      final isPlayingState = audioState == AudioState.playing;
      final isThisSong = song.id == (_audio.current?.id ?? 0);
      emit(state.copyWith(isPlaying: isPlayingState && isThisSong));
    });
    // When songs have been selected.
    onSelection = selectionBarCubit.listen((selectionState) {
      final isSelected = selectionState is SelectionBarActive &&
          selectionState.selected.contains(song);
      emit(state.copyWith(isSelected: isSelected));
    });
  }

  @override
  Future<void> close() {
    onPlaying.cancel();
    onDownload.cancel();
    onSelection.cancel();
    return super.close();
  }
}
