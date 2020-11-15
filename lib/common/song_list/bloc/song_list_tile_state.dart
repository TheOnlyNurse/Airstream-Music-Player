part of 'song_list_tile_bloc.dart';

class SongListTileState extends Equatable {
  final double cachePercent;
  final bool isPlaying;

  const SongListTileState({this.cachePercent = 0, this.isPlaying = false});

  SongListTileState copyWith({double cachePercent, bool isPlaying}) {
    return SongListTileState(
      cachePercent: cachePercent ?? this.cachePercent,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object> get props => [cachePercent, isPlaying];
}
