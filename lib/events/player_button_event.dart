abstract class PlayerButtonEvent {}

// Events from user interaction with the button

class PauseSong extends PlayerButtonEvent {}

class ResumeSong extends PlayerButtonEvent {}

// Events from streams

class DownloadEvent extends PlayerButtonEvent {
  final int percent;

  DownloadEvent(this.percent);
}

class SongHasStopped extends PlayerButtonEvent {}

class SongIsPlaying extends PlayerButtonEvent {}

class SongIsPaused extends PlayerButtonEvent {}
