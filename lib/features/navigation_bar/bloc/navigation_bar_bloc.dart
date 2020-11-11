import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../common/global_assets.dart';
import '../../../common/repository/repository.dart';
import '../../mini_player/bloc/mini_player_bloc.dart';

part 'navigation_bar_event.dart';
part 'navigation_bar_state.dart';

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  NavigationBarBloc({
    @required MiniPlayerBloc playerBloc,
  })  : assert(playerBloc != null),
        super(const NavigationBarState()) {
    _buttonState = playerBloc.listen((state) {
      if (state is MiniPlayerHidden) {
        add(const NavigationBarNotch(isNotched: false));
      } else {
        add(const NavigationBarNotch(isNotched: true));
      }
    });

    _offlineState = _repository.settings.onChange.listen((hasChanged) {
      add(NavigationBarNetworkChange());
    });
  }

  final _repository = Repository();
  StreamSubscription _buttonState;
  StreamSubscription _offlineState;

  @override
  Stream<NavigationBarState> mapEventToState(NavigationBarEvent event) async* {
    if (event is NavigationBarTapped) {
      final navigatorState = libraryNavigator.currentState;
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
