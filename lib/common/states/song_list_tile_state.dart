import 'package:equatable/equatable.dart';

abstract class SongListTileState extends Equatable {
  const SongListTileState();

  @override
  List<Object> get props => [];
}

class SongListTileInitial extends SongListTileState {}

class SongListTileSuccess extends SongListTileState {
  final int cachePercent;
  final bool isPlaying;

  const SongListTileSuccess({this.cachePercent = 0, this.isPlaying = false});

  SongListTileSuccess copyWith({int cachePercent, bool isPlaying}) {
    return SongListTileSuccess(
      cachePercent: cachePercent ?? this.cachePercent,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object> get props => [cachePercent, isPlaying];
}
