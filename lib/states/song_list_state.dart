import 'package:airstream/data_providers/moor_database.dart';
import 'package:flutter/material.dart';

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

  SongListSuccess({@required this.songList, List<int> selected, Map<int, Song> removeMap})
      : assert(songList != null),
        this.selected = selected ?? [],
        this.removeMap = removeMap ?? <int, Song>{};

  SongListSuccess copyWith({
    List<Song> songList,
    List<int> selected,
    Map<int, Song> removeMap,
  }) =>
      SongListSuccess(
        songList: songList ?? this.songList,
        selected: selected ?? this.selected,
        removeMap: removeMap,
      );
}
