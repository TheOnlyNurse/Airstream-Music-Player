import 'package:flutter/material.dart';

abstract class PlayerButtonState {}

class NoMusic extends PlayerButtonState {}

class MusicPlaying extends PlayerButtonState {}

class MusicPaused extends PlayerButtonState {}

class DownloadingMusic extends PlayerButtonState {
  final int percentage;

  DownloadingMusic({@required this.percentage});
}
