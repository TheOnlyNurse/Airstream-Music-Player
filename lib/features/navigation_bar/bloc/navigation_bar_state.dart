part of 'navigation_bar_bloc.dart';

class NavigationBarState extends Equatable {
  const NavigationBarState({
    this.isNotched = false,
    this.isOffline = false,
    this.pageIndex = 0,
  });

  final bool isNotched;
  final bool isOffline;
  final int pageIndex;

  NavigationBarState copyWith({
    bool isNotched,
    bool isOffline,
    int pageIndex,
  }) {
    return NavigationBarState(
      isNotched: isNotched ?? this.isNotched,
      isOffline: isOffline ?? this.isOffline,
      pageIndex: pageIndex ?? this.pageIndex,
    );
  }

  @override
  List<Object> get props => [isNotched, isOffline, pageIndex];
}
