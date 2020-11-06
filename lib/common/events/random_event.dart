import 'package:equatable/equatable.dart';

abstract class RandomEvent extends Equatable {
  const RandomEvent();

  @override
  List<Object> get props => [];
}

class RandomFetch extends RandomEvent {}

class RandomNext extends RandomEvent {}
