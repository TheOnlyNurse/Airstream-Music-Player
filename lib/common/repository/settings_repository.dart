import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:hive/hive.dart';

import '../providers/settings_provider.dart';

class SettingsRepository {
  SettingsRepository({SettingsProvider provider})
      : _database = provider ?? SettingsProvider(hive: Hive.box('settings')) {
    // Capture connectivity changes.
    Connectivity().onConnectivityChanged.listen(_onConnectivityChange);
  }

  /// Database that holds settings information.
  final SettingsProvider _database;

  /// Controller used for connectivity status.
  final _connectivityChanged = StreamController<bool>.broadcast();

  /// Returns a stream of app connectivity.
  Stream<bool> get connectivityChanged => _connectivityChanged.stream;

  /// Returns whether the last emitted value indicates that app is online or not.
  bool get isOnline => _database.query<bool>(SettingType.isOnline);

  /// Inverse of [isOnline].
  bool get isOffline => !isOnline;

  /// Toggles between offline/online states.
  void toggleOnline() {
    _database.change(SettingType.isOnline, isOffline);
    _connectivityChanged.add(isOffline);
  }

  /// Whether the app will automatically turn to offline state when switching to mobile connectivity.
  bool get autoOffline => _database.query<bool>(SettingType.autoOffline);

  /// Toggles the [autoOffline] state.
  void toggleAutoOffline() {
    _database.change(SettingType.autoOffline, !autoOffline);
  }

  /// Returns the maximum audio cache size in bytes.
  int get audioCache {
    return _database.query<int>(SettingType.musicCache) * 1024 * 1024;
  }

  @Deprecated('Create custom query function inside repository instead')
  dynamic query(SettingType type) => _database.query(type);

  @Deprecated('Create custom change function inside repository instead.')
  void change(SettingType type, dynamic newValue) {
    _database.change(type, newValue);
  }

  List<int> range(SettingType type) => _database.range(type);

  /// Toggle connectivity status depending on [result] and user settings.
  void _onConnectivityChange(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        if (isOffline) toggleOnline();
        break;
      case ConnectivityResult.mobile:
        if (autoOffline && isOnline) toggleOnline();
        break;
      case ConnectivityResult.none:
        if (isOnline) toggleOnline();
        break;
    }
  }
}
