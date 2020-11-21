import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../common/repository/settings_repository.dart';
import '../../../global_assets.dart';
import '../../mini_player/bloc/mini_player_bloc.dart';

part 'navigation_bar_event.dart';
part 'navigation_bar_state.dart';

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  NavigationBarBloc({
    @required MiniPlayerBloc playerBloc,
    SettingsRepository settings,
  })  : assert(playerBloc != null),
        _settings = getIt<SettingsRepository>(settings),
        super(const NavigationBarState()) {
    _buttonState = playerBloc.listen((state) {
      if (state is MiniPlayerHidden) {
        add(const NavigationBarNotch(isNotched: false));
      } else {
        add(const NavigationBarNotch(isNotched: true));
      }
    });

    _offlineState = _settings.connectivityChanged.listen((isOnline) {
      add(NavigationBarNetworkChange());
    });
  }

  final SettingsRepository _settings;
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
      final newState = _settings.isOffline;
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
