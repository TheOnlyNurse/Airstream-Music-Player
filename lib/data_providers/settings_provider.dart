class SettingsProvider {
  static final SettingsProvider _instance = SettingsProvider._internal();

  SettingsProvider._internal() {
    print("SettingsProvider initialised.");
  }

  factory SettingsProvider() => _instance;

  int get prefetchValue => 1;
}
