import 'package:flutter/material.dart';

abstract class NavigationBarState {
  const NavigationBarState();
}

class NavigationBarLoaded extends NavigationBarState {
  final int index;
  final bool musicPlaying;
  final int newIndex;
  final bool isDoubleTap;
  final double barHeight;

  const NavigationBarLoaded({
    @required this.index,
    @required this.musicPlaying,
    this.newIndex = -1,
    this.isDoubleTap = false,
    this.barHeight = 60,
  });

  NavigationBarLoaded copyWith({
		int index,
		bool musicPlaying,
		int newIndex,
		bool isDoubleTap,
		double barHeight,
	}) =>
      NavigationBarLoaded(
				index: index ?? this.index,
				musicPlaying: musicPlaying ?? this.musicPlaying,
				newIndex: newIndex ?? -1,
				isDoubleTap: isDoubleTap ?? false,
				barHeight: barHeight ?? 60,
      );
}
