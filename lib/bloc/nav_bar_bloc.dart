import 'package:airstream/events/nav_bar_event.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'package:bloc/bloc.dart';
import 'dart:async';

class NavigationBarBloc extends Bloc<NavigationBarEvent, NavigationBarState> {
  @override
  NavigationBarState get initialState => HomePage(index: 0);

  @override
  Stream<NavigationBarState> mapEventToState(NavigationBarEvent event) async* {
    if (event is NavigateToPage) {
      yield HomePage(index: event.index);
    }
    if (event is UpdateNavBar) {
      yield HomePage(index: event.index, shouldNavigate: false);
    }
  }
}
