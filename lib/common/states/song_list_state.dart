import 'package:flutter/material.dart';

/// Internal
import '../providers/moor_database.dart';

abstract class SongListState {}

class SongListInitial extends SongListState {}

class SongListFailure extends SongListState {
  final Widget errorMessage;

  SongListFailure(this.errorMessage);
}

class SongListSuccess extends SongListState {
  final List<Song> songList;
  final List<int> selected;
  final Map<int, Song> removeMap;

  SongListSuccess({
    List<Song> songList,
    List<int> selected,
    Map<int, Song> removeMap,
  })  : this.songList = songList ?? <Song>[],
        this.selected = selected ?? <int>[],
        this.removeMap = removeMap ?? <int, Song>{};

  SongListSuccess copyWith({
    List<Song> songList,
    List<int> selected,
    Map<int, Song> removeMap,
  }) {
    return SongListSuccess(
      songList: songList ?? this.songList,
      selected: selected ?? this.selected,
      removeMap: removeMap,
    );
  }
}
