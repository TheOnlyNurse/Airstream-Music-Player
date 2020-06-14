import 'package:airstream/data_providers/settings_provider.dart';

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
