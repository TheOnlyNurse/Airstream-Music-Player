import '../repository/communication.dart';

abstract class SettingsEvent {}

class SettingsStarted extends SettingsEvent {}

class SettingsChanging extends SettingsEvent {
  final SettingType type;
  final dynamic value;

  SettingsChanging(this.type, this.value);
}

class SettingsChanged extends SettingsEvent {
	final SettingType type;
	final dynamic value;

	SettingsChanged(this.type, this.value);
}
