import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../common/providers/repository/repository.dart';
import '../../../common/repository/communication.dart';

part 'slider_event.dart';
part 'slider_state.dart';

class SliderBloc extends Bloc<SliderEvent, SliderState> {
  SliderBloc() : super(SliderInitial());

  final _repository = Repository();
  SettingType type;

  int generatorDivisions(List<int> range, {int divisions = 10}) {
    final span = range[1] - range[0];
    // If the current division is too large, return the last appropriate division
    if (span ~/ divisions < 10) return span * 10 ~/ divisions;
    // Else continue increasing division size by magnitudes of 10
    return generatorDivisions(range, divisions: divisions * 10);
  }

  @override
  Stream<SliderState> mapEventToState(SliderEvent event) async* {
    final currentState = state;

    if (event is SliderFetch) {
      type = event.type;
      final current = _repository.settings.query(type) as int;
      final range = _repository.settings.range(type);
      final divisions = generatorDivisions(range);

      yield SliderSuccess(
        current.toDouble(),
        range[0].toDouble(),
        range[1].toDouble(),
        divisions,
      );
    }

    if (event is SliderUpdate && currentState is SliderSuccess) {
      yield currentState.copyWith(value: event.value);
    }
    if (event is SliderFinished && currentState is SliderSuccess) {
      _repository.settings.change(type, event.value.floor());
      final savedValue = _repository.settings.query(type) as int;
      yield currentState.copyWith(value: savedValue.toDouble());
    }
  }
}
