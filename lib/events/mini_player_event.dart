abstract class MinimisedPlayerEvent {}

// Events from user interaction with the button

class ButtonPlayPause extends MinimisedPlayerEvent {}

// Events from streams

class ButtonDownload extends MinimisedPlayerEvent {
  final int percentage;

  ButtonDownload(this.percentage);
}

class ButtonAudioStopped extends MinimisedPlayerEvent {}

class ButtonAudioPlaying extends MinimisedPlayerEvent {}

class ButtonAudioPaused extends MinimisedPlayerEvent {}
