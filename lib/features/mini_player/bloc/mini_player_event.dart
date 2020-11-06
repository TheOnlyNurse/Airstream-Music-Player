part of 'mini_player_bloc.dart';

abstract class MiniPlayerEvent extends Equatable {
  const MiniPlayerEvent();

  @override
  List<Object> get props => [];
}

/// Events from user interaction with the button
class MiniPlayerPlayPause extends MiniPlayerEvent {}

/// Events from streams
class MiniPlayerStopped extends MiniPlayerEvent {}

class MiniPlayerPlaying extends MiniPlayerEvent {}

class MiniPlayerPaused extends MiniPlayerEvent {}

class MiniPlayerDragEnd extends MiniPlayerEvent {
  const MiniPlayerDragEnd(this._screenOffset);

  final double _screenOffset;

  @override
  List<Object> get props => [_screenOffset];

  int get screenOffset => _screenOffset.floor();
}

class MiniPlayerDragStarted extends MiniPlayerEvent {}
