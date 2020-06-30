part of repository_library;

class _SettingsRepository {
  final _provider = SettingsProvider();

  Stream<SettingType> get onChange => _provider.onSettingsChange;

  bool get isOffline {
    final bool isOffline = _provider.query(SettingType.isOffline);
    return isOffline;
  }

  dynamic query(SettingType type) => _provider.query(type);

  void change(SettingType type, dynamic newValue) {
    _provider.change(type, newValue);
  }

  List<int> range(SettingType type) => _provider.range(type);
}
