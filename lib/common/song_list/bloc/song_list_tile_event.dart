part of 'song_list_tile_bloc.dart';

abstract class SongListTileEvent extends Equatable {
  const SongListTileEvent();

  @override
  List<Object> get props => [];
}

class SongListTileFetch extends SongListTileEvent {}

class SongListTileDownload extends SongListTileEvent {
  final double percentage;

  const SongListTileDownload(this.percentage);

  @override
  List<Object> get props => [percentage];
}

class SongListTilePlaying extends SongListTileEvent {
  final bool isPlaying;

  const SongListTilePlaying({this.isPlaying});

  @override
  List<Object> get props => [isPlaying];
}

class SongListTileFinished extends SongListTileEvent {}

class SongListTileReset extends SongListTileEvent {}
