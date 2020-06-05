import 'package:flutter/material.dart';

abstract class PlayerButtonState {}

class ButtonNoAudio extends PlayerButtonState {}

class ButtonAudioIsPlaying extends PlayerButtonState {}

class ButtonAudioIsPaused extends PlayerButtonState {}

class ButtonIsDownloading extends PlayerButtonState {
  final int percentage;

  ButtonIsDownloading({@required this.percentage});
}
