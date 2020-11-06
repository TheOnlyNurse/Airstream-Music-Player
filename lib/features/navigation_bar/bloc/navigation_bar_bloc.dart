import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Internal links
import '../../../common/providers/repository/repository.dart';
import '../../mini_player/bloc/mini_player_bloc.dart';

part 'navigation_bar_state.dart';

part 'navigation_bar_event.dart';

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  NavigationBarBloc({
    @required MiniPlayerBloc playerBloc,
    @required this.navigatorKey,
  })  : assert(playerBloc != null),
        assert(navigatorKey != null),
        super(NavigationBarState()) {
    _buttonState = playerBloc.listen((state) {
      if (state is MiniPlayerHidden) {
        this.add(NavigationBarNotch(false));
      } else {
        this.add(NavigationBarNotch(true));
      }
    });

    _offlineState = _repository.settings.onChange.listen((hasChanged) {
      this.add(NavigationBarNetworkChange());
    });
  }

  final _repository = Repository();
  final GlobalKey<NavigatorState> navigatorKey;
  StreamSubscription _buttonState;
  StreamSubscription _offlineState;

  @override
  Stream<NavigationBarState> mapEventToState(NavigationBarEvent event) async* {
    if (event is NavigationBarTapped) {
      var navigatorState = navigatorKey.currentState;
      if (navigatorState.canPop()) {
        navigatorState.popUntil((route) => route.isFirst);
      } else {
        yield state.copyWith(pageIndex: event.index);
      }
    }

    if (event is NavigationBarNotch) {
      yield state.copyWith(isNotched: event.isNotched);
    }

    if (event is NavigationBarNetworkChange) {
      final newState = _repository.settings.isOffline;
      if (state.isOffline != newState) {
        yield state.copyWith(isOffline: newState);
      }
    }
  }

  @override
  Future<void> close() {
    _offlineState.cancel();
    _buttonState.cancel();
    return super.close();
  }
}
