import 'package:equatable/equatable.dart';

abstract class NavigationBarState extends Equatable {
  const NavigationBarState();

  @override
  List<Object> get props => [];
}

class NavigationBarSuccess extends NavigationBarState {
  final bool isNotched;
  final int index;

  const NavigationBarSuccess({this.isNotched, this.index});

  NavigationBarSuccess copyWith({bool isNotched, int index}) => NavigationBarSuccess(
        isNotched: isNotched ?? this.isNotched,
        index: index ?? this.index,
      );

  @override
  List<Object> get props => [index, isNotched];
}
