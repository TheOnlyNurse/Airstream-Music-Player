part of 'position_bloc.dart';

abstract class PositionEvent extends Equatable {
  const PositionEvent();

  @override
  List<Object> get props => [];
}

class PositionNew extends PositionEvent {
  final Duration position;

  const PositionNew(this.position);

  @override
  List<Object> get props => [position];
}

class PositionDownload extends PositionEvent {
  final int percentage;

  const PositionDownload(this.percentage);

  @override
  List<Object> get props => [percentage];
}

class PositionRefresh extends PositionEvent {}
