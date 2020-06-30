import 'package:equatable/equatable.dart';

abstract class SliderState extends Equatable {
  const SliderState();

  @override
  List<Object> get props => [];
}

class SliderInitial extends SliderState {}

class SliderSuccess extends SliderState {
  final double value;
  final double min;
  final double max;
  final int divisions;

  const SliderSuccess(this.value, this.min, this.max, this.divisions);

  @override
  List<Object> get props => [value];

  SliderSuccess copyWith({double value}) => SliderSuccess(
        value ?? this.value,
        this.min,
        this.max,
        this.divisions,
      );
}
