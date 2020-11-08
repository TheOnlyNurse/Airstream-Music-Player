part of 'position_bloc.dart';

abstract class PositionState extends Equatable {
  const PositionState();

  @override
  List<Object> get props => [];
}

class PositionInitial extends PositionState {}

class PositionSuccess extends PositionState {
  final Duration _current;
  final Duration _max;

  const PositionSuccess(this._current, this._max);

  String get maxText => _formatDuration(_max);

  String get currentText => _formatDuration(_current);

  double get maxDuration => _max.inSeconds.roundToDouble();

  double get currentPosition => _current.inSeconds.roundToDouble();

  String _formatDuration(Duration d) => d.toString().substring(2, 7);

  PositionSuccess copyWith({Duration current}) => PositionSuccess(
        current ?? _current,
        _max,
      );

  @override
  List<Object> get props => [_current, _max];
}

class PositionLoading extends PositionState {
  final int percentage;

  const PositionLoading(this.percentage);

  @override
  List<Object> get props => [percentage];
}
