import 'package:equatable/equatable.dart';

abstract class NavigationBarEvent extends Equatable {
  const NavigationBarEvent();

  @override
  List<Object> get props => [];
}

class NavigationBarNotch extends NavigationBarEvent {
  const NavigationBarNotch({this.isNotched});

  final bool isNotched;
}

class NavigationBarNetworkChange extends NavigationBarEvent {}

class NavigationBarTapped extends NavigationBarEvent {
  const NavigationBarTapped({this.index = 0});

  final int index;
}
