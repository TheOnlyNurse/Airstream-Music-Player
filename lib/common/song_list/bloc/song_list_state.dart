part of 'song_list_bloc.dart';

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
  })  : songList = songList ?? <Song>[],
        selected = selected ?? <int>[],
        removeMap = removeMap ?? <int, Song>{};

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
