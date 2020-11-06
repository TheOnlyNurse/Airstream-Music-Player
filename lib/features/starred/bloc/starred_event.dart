part of 'starred_bloc.dart';

abstract class StarredEvent extends Equatable {
  const StarredEvent();

  @override
  List<Object> get props => [];
}

class StarredFetch extends StarredEvent {}
