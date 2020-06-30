import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/settings_slider_event.dart';
import 'package:airstream/states/settings_slider_state.dart';

// Ease of use barrel
export 'package:airstream/events/settings_slider_event.dart';
export 'package:airstream/states/settings_slider_state.dart';

class SliderBloc extends Bloc<SliderEvent, SliderState> {
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
  SliderState get initialState => SliderInitial();

  @override
  Stream<SliderState> mapEventToState(SliderEvent event) async* {
    final currentState = state;

    if (event is SliderFetch) {
      type = event.type;
      final int current = _repository.settings.query(type);
      final List<int> range = _repository.settings.range(type);
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
      final savedValue = _repository.settings.query(type).toDouble();
      yield currentState.copyWith(value: savedValue);
    }
  }
}
