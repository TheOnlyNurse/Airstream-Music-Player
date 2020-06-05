abstract class PlayerButtonEvent {}

// Events from user interaction with the button

class ButtonPlayPause extends PlayerButtonEvent {}

// Events from streams

class ButtonDownload extends PlayerButtonEvent {
  final int percentage;

  ButtonDownload(this.percentage);
}

class ButtonAudioStopped extends PlayerButtonEvent {}

class ButtonAudioPlaying extends PlayerButtonEvent {}

class ButtonAudioPaused extends PlayerButtonEvent {}
