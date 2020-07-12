import 'package:equatable/equatable.dart';

abstract class NavigationBarEvent extends Equatable {
  const NavigationBarEvent();

  @override
  List<Object> get props => [];
}

class NavigationBarNotch extends NavigationBarEvent {
  final bool isNotched;

  const NavigationBarNotch(this.isNotched);
}

class NavigationBarNetworkChange extends NavigationBarEvent {}
