import 'package:airstream/models/percentage_model.dart';

abstract class MinimisedPlayerEvent {}

// Events from user interaction with the button

class ButtonPlayPause extends MinimisedPlayerEvent {}

// Events from streams

class ButtonDownload extends MinimisedPlayerEvent {
  final PercentageModel percentModel;

	ButtonDownload(this.percentModel);
}

class ButtonAudioStopped extends MinimisedPlayerEvent {}

class ButtonAudioPlaying extends MinimisedPlayerEvent {}

class ButtonAudioPaused extends MinimisedPlayerEvent {}
