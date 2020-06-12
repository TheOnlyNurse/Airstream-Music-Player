import 'package:flutter/material.dart';

abstract class NavigationBarState {
  const NavigationBarState();
}

class NavigationBarLoaded extends NavigationBarState {
  final int index;
  final bool musicPlaying;
  final bool isNewDisplay;
  final double barHeight;

  const NavigationBarLoaded({
    @required this.index,
    @required this.musicPlaying,
    this.barHeight = 60,
    this.isNewDisplay = false,
  });

  NavigationBarLoaded copyWith({
    int index,
    bool musicPlaying,
    bool isNewDisplay,
    double barHeight,
  }) =>
      NavigationBarLoaded(
        index: index ?? this.index,
        musicPlaying: musicPlaying ?? this.musicPlaying,
        isNewDisplay: isNewDisplay ?? false,
        barHeight: barHeight ?? 60,
      );
}
