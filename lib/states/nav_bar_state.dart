import 'package:flutter/material.dart';

abstract class NavigationBarState {
  const NavigationBarState();
}

class NavigationBarLoaded extends NavigationBarState {
  final int index;
  final bool musicPlaying;
  final bool isNewScreen;
  final bool isDoubleTap;
  final double barHeight;

  const NavigationBarLoaded({
    @required this.index,
    @required this.musicPlaying,
    this.isNewScreen = false,
    this.isDoubleTap = false,
    this.barHeight = 60,
  });

  NavigationBarLoaded copyWith({
		int index,
		bool musicPlaying,
		bool isNewScreen,
		bool isDoubleTap,
		double barHeight,
	}) =>
      NavigationBarLoaded(
				index: index ?? this.index,
				musicPlaying: musicPlaying ?? this.musicPlaying,
				isNewScreen: isNewScreen ?? false,
				isDoubleTap: isDoubleTap ?? false,
				barHeight: barHeight ?? 60,
      );
}
