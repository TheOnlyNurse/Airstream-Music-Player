import 'package:equatable/equatable.dart';

abstract class NavigationBarState extends Equatable {
  const NavigationBarState();

  @override
  List<Object> get props => [];
}

class NavigationBarSuccess extends NavigationBarState {
  final bool isNotched;
  final bool isOffline;

  const NavigationBarSuccess({
    this.isNotched = false,
    this.isOffline = false,
  });

  NavigationBarSuccess copyWith({bool isNotched, bool isOffline, int index}) =>
      NavigationBarSuccess(
        isNotched: isNotched ?? this.isNotched,
        isOffline: isOffline ?? this.isOffline,
      );

  @override
  List<Object> get props => [isNotched, isOffline];
}
