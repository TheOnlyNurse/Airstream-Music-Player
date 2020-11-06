part of 'repository.dart';

class _SettingsRepository {
  final _provider = SettingsProvider();

  Stream<SettingType> get onChange => _provider.onSettingsChange;

  bool get isOffline {
    return _provider.query<bool>(SettingType.isOffline);
  }

  bool get isOnline => !isOffline;

  /// Returns the max audio cache size in bytes.
  int get maxAudioCacheSize {
    return _provider.query<int>(SettingType.musicCache) * 1024 * 1024;
  }

  dynamic query(SettingType type) => _provider.query(type);

  void change(SettingType type, dynamic newValue) {
    _provider.change(type, newValue);
  }

  List<int> range(SettingType type) => _provider.range(type);
}
