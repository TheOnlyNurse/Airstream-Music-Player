import 'package:equatable/equatable.dart';

abstract class NavigationBarState extends Equatable {
  const NavigationBarState();

  @override
  List<Object> get props => [];
}

class NavigationBarSuccess extends NavigationBarState {
  final bool isNotched;
  final bool isOffline;
  final int index;

  const NavigationBarSuccess({
    this.isNotched = false,
    this.isOffline = false,
    this.index = 0,
  });

  NavigationBarSuccess copyWith({bool isNotched, bool isOffline, int index}) =>
      NavigationBarSuccess(
        isNotched: isNotched ?? this.isNotched,
        isOffline: isOffline ?? this.isOffline,
        index: index ?? this.index,
      );

  @override
  List<Object> get props => [isNotched, isOffline, index];
}
