import 'package:airstream/bloc/mini_player_bloc.dart';
import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/states/mini_player_state.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:airstream/barrel/bloc_basics.dart';
import 'package:flutter/material.dart';

// Barrel for ease of importing
export 'package:airstream/events/nav_bar_event.dart';
export 'package:airstream/states/nav_bar_state.dart';

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  final PageController pageController;
  final GlobalKey<NavigatorState> navigatorKey;
  final _repository = Repository();
  StreamSubscription _buttonState;
  StreamSubscription _offlineState;

  NavigationBarBloc({
    @required MinimisedPlayerBloc playerBloc,
    @required this.pageController,
    @required this.navigatorKey,
  }) {
    assert(playerBloc != null);
    assert(pageController != null);
    assert(navigatorKey != null);

    _buttonState = playerBloc.listen((state) {
      if (state is ButtonNoAudio) {
        this.add(NavigationBarNotch(false));
      } else {
        this.add(NavigationBarNotch(true));
      }
    });
    _offlineState = _repository.settings.onChange.listen((hasChanged) {
      this.add(NavigationBarNetworkChange());
    });
  }

  @override
  NavigationBarState get initialState => NavigationBarSuccess();

  @override
  Stream<NavigationBarState> mapEventToState(NavigationBarEvent event) async* {
    final currentState = state;

    if (currentState is NavigationBarSuccess) {
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
      if (event is NavigationBarUpdate) {
        yield currentState.copyWith(index: event.index);
      }
      if (event is NavigationBarNotch) {
        yield currentState.copyWith(isNotched: event.isNotched);
      }

      if (event is NavigationBarNetworkChange) {
        final newState = _repository.settings.isOffline;
        if (currentState.isOffline != newState) {
          yield currentState.copyWith(isOffline: newState);
        }
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
