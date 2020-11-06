abstract class MiniPlayerEvent {}

/// Events from user interaction with the button
class MiniPlayerPlayPause extends MiniPlayerEvent {}

/// Events from streams
class MiniPlayerStopped extends MiniPlayerEvent {}

class MiniPlayerPlaying extends MiniPlayerEvent {}

class MiniPlayerPaused extends MiniPlayerEvent {}
