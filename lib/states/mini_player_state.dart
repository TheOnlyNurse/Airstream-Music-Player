import 'package:flutter/material.dart';

abstract class MinimisedPlayerState {}

class ButtonNoAudio extends MinimisedPlayerState {}

class ButtonFailure extends MinimisedPlayerState {}

class ButtonAudioIsPlaying extends MinimisedPlayerState {}

class ButtonAudioIsPaused extends MinimisedPlayerState {}

class ButtonIsDownloading extends MinimisedPlayerState {
  final int percentage;

  ButtonIsDownloading({@required this.percentage});
}
