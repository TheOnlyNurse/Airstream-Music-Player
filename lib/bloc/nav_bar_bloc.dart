import 'package:bloc/bloc.dart';
import 'dart:async';

import 'package:flutter/material.dart';

abstract class NavigationBarEvent {}

class NavigateToPage extends NavigationBarEvent {
  final int index;

  NavigateToPage({this.index});
}

class UpdateNavBar extends NavigationBarEvent {
  final int index;

  UpdateNavBar({this.index});
}

class NavBarDragEvent extends NavigationBarEvent {
  final double height;

  NavBarDragEvent({this.height = 0});
}

abstract class NavigationBarState {
  int get index;
}

class DisplayNavChange extends NavigationBarState {
  final int index;
  final bool isNewDisplay;

  DisplayNavChange({@required this.index, this.isNewDisplay = false});
}

class NavHeightChanged extends NavigationBarState {
  final int index;
  final double barHeight;

  NavHeightChanged({this.index, this.barHeight});
}

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  @override
  NavigationBarState get initialState => DisplayNavChange(index: 0);

  @override
  Stream<NavigationBarState> mapEventToState(NavigationBarEvent event) async* {
    final currentState = state;

    if (event is NavigateToPage) {
      yield DisplayNavChange(index: event.index, isNewDisplay: true);
    }
    if (event is UpdateNavBar) {
      yield DisplayNavChange(index: event.index);
    }
    if (event is NavBarDragEvent) {
      if (event.height < 60 && event.height > 30)
        yield NavHeightChanged(index: currentState.index, barHeight: 125);
      if (event.height < 125 && event.height > 61)
        yield NavHeightChanged(index: currentState.index, barHeight: 60);
    }
  }
}
