import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/settings_event.dart';
import 'package:airstream/states/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState => SettingsInitial();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    final currentState = state;

    if (event is SettingsStarted) {
      final response = await Repository().settings.get();
      yield SettingsSuccess(
        prefetch: response.prefetch,
        isOffline: response.isOffline,
        imageCacheSize: response.imageCacheSize,
        musicCacheSize: response.musicCacheSize,
      );
    }

    if (currentState is SettingsSuccess) {
      if (event is SettingsChanged) {
        Repository()..settings.set(event.type, event.value);

        switch (event.type) {
          case SettingsChangedType.prefetch:
            yield currentState.copyWith(prefetch: event.value);
            break;
          case SettingsChangedType.isOffline:
            yield currentState.copyWith(isOffline: event.value);
            break;
          case SettingsChangedType.imageCache:
            yield currentState.copyWith(imageCacheSize: event.value);
            break;
          case SettingsChangedType.musicCache:
            yield currentState.copyWith(musicCacheSize: event.value);
            break;
        }
      }
      if (event is SettingsChanging) {
        switch (event.type) {
          case SettingsChangedType.prefetch:
            yield currentState.copyWith(prefetch: event.value);
            break;
          case SettingsChangedType.isOffline:
            yield currentState.copyWith(isOffline: event.value);
            break;
          case SettingsChangedType.imageCache:
            yield currentState.copyWith(imageCacheSize: event.value);
            break;
          case SettingsChangedType.musicCache:
            yield currentState.copyWith(musicCacheSize: event.value);
            break;
        }
      }
    }
  }
}
