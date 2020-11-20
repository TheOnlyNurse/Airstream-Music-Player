part of 'song_list_tile_cubit.dart';

class SongListTileState extends Equatable {
  final double cachePercent;
  final bool isPlaying;
  final bool isSelected;

  const SongListTileState({
    this.cachePercent = 1,
    this.isPlaying = false,
    this.isSelected = false,
  });

  SongListTileState copyWith(
      {double cachePercent, bool isPlaying, bool isSelected}) {
    return SongListTileState(
      cachePercent: cachePercent ?? this.cachePercent,
      isPlaying: isPlaying ?? this.isPlaying,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  List<Object> get props => [cachePercent, isPlaying, isSelected];
}
