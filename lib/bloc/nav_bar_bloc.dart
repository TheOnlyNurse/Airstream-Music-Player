import 'package:airstream/bloc/mini_player_bloc.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/states/mini_player_state.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  StreamSubscription _buttonState;
  PageController pageController;
  GlobalKey<NavigatorState> navigatorKey;

  NavigationBarBloc({
    MinimisedPlayerBloc playerBloc,
    PageController pageController,
    this.navigatorKey,
  }) {
    assert(playerBloc != null && pageController != null);

    this.pageController = pageController;
    _buttonState = playerBloc.listen((state) {
      if (state is ButtonNoAudio) {
        this.add(NavigationBarNotch(false));
      } else {
        this.add(NavigationBarNotch(true));
      }
    });
  }

  @override
  NavigationBarState get initialState => NavigationBarSuccess(
        index: 0,
        isNotched: false,
      );

  @override
  Stream<NavigationBarState> mapEventToState(NavigationBarEvent event) async* {
    final currentState = state;

    if (event is NavigationBarNavigate) {
      if (navigatorKey.currentState.canPop()) {
        navigatorKey.currentState.popUntil((route) => route.isFirst);
      } else {
        pageController.animateToPage(
          event.index,
          duration: Duration(seconds: 1),
          curve: Curves.easeOutQuart,
        );
      }
    }

    if (currentState is NavigationBarSuccess) {
      if (event is NavigationBarUpdate) {
        yield currentState.copyWith(index: event.index);
      }

      if (event is NavigationBarNotch) {
        yield currentState.copyWith(isNotched: event.isNotched);
      }
    }
  }

  @override
  Future<void> close() {
    _buttonState.cancel();
    return super.close();
  }
}
