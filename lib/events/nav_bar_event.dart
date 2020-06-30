import 'package:equatable/equatable.dart';

abstract class NavigationBarEvent extends Equatable {
  const NavigationBarEvent();

  @override
  List<Object> get props => [];
}

class NavigationBarNavigate extends NavigationBarEvent {
  final int index;

  const NavigationBarNavigate(this.index);
}

class NavigationBarUpdate extends NavigationBarEvent {
  final int index;

  const NavigationBarUpdate(this.index);
}

class NavigationBarNotch extends NavigationBarEvent {
  final bool isNotched;

  const NavigationBarNotch(this.isNotched);
}

class NavigationBarNetworkChange extends NavigationBarEvent {}
