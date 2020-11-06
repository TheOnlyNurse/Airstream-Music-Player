part of 'slider_bloc.dart';

abstract class SliderEvent extends Equatable {
  const SliderEvent();

  @override
  List<Object> get props => [];
}

class SliderFetch extends SliderEvent {
  final SettingType type;

  const SliderFetch(this.type);

  @override
  List<Object> get props => [type];
}

class SliderUpdate extends SliderEvent {
  final double value;

  const SliderUpdate(this.value);

  @override
  List<Object> get props => [value];
}

class SliderFinished extends SliderEvent {
  final double value;

  const SliderFinished(this.value);

  @override
  List<Object> get props => [value];
}
