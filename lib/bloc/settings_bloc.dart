import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:bloc/bloc.dart';

abstract class SettingsEvent {}

class SettingsStarted extends SettingsEvent {}

class SettingsChanging extends SettingsEvent {
  final SettingsChangedType type;
  final dynamic value;

  SettingsChanging(this.type, this.value);
}

class SettingsChanged extends SettingsEvent {
  final SettingsChangedType type;
  final dynamic value;

  SettingsChanged(this.type, this.value);
}

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final int prefetch;
  final bool isOffline;
  final int imageCacheSize;
  final int musicCacheSize;

  SettingsSuccess(
      {this.prefetch, this.isOffline, this.imageCacheSize, this.musicCacheSize});

  SettingsSuccess copyWith({
    int prefetch,
    bool isOffline,
    int imageCacheSize,
    int musicCacheSize,
  }) =>
      SettingsSuccess(
        prefetch: prefetch ?? this.prefetch,
        isOffline: isOffline ?? this.isOffline,
        imageCacheSize: imageCacheSize ?? this.imageCacheSize,
        musicCacheSize: musicCacheSize ?? this.musicCacheSize,
      );
}

class SettingsFailure extends SettingsState {}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  @override
  SettingsState get initialState => SettingsInitial();

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    final currentState = state;

    if (event is SettingsStarted) {
      final response = await Repository().getSettings();
      yield SettingsSuccess(
        prefetch: response.prefetch,
        isOffline: response.isOffline,
        imageCacheSize: response.imageCacheSize,
        musicCacheSize: response.musicCacheSize,
      );
    }

    if (currentState is SettingsSuccess) {
      if (event is SettingsChanged) {
        Repository().setSettings(event.type, event.value);

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
