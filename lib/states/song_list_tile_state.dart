import 'package:equatable/equatable.dart';

abstract class SongListTileState extends Equatable {
  const SongListTileState();

  @override
  List<Object> get props => [];
}

class SongListTileIsEmpty extends SongListTileState {}

class SongListTileIsDownloading extends SongListTileState {
  final int percentage;

  const SongListTileIsDownloading(this.percentage);

  @override
  List<Object> get props => [percentage];
}

class SongListTileIsFinished extends SongListTileState {}

class SongListTileIsPlaying extends SongListTileState {}

class SongListTileIsPaused extends SongListTileState {}
