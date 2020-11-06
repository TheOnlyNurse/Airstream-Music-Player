part of 'mini_player_bloc.dart';

abstract class MiniPlayerState extends Equatable {
  const MiniPlayerState();

  @override
  List<Object> get props => [];
}

class MiniPlayerHidden extends MiniPlayerState {}

class MiniPlayerShown extends MiniPlayerState {
  const MiniPlayerShown(this.isPlaying, {this.isMoving = false});

  final bool isPlaying;
  final bool isMoving;

  @override
  List<Object> get props => [isPlaying, isMoving];

  MiniPlayerShown copyWith({bool isPlaying, bool isMoving}) =>
      MiniPlayerShown(
        isPlaying ?? this.isPlaying,
        isMoving: isMoving ?? false,
      );
}
