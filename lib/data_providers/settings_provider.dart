import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/barrel/provider_basics.dart';
import 'package:connectivity/connectivity.dart';

class SettingsProvider {
  Box get _hiveBox => Hive.box('settings');

  /// Global
  /// Listenable stream of changed settings
  Stream<SettingType> get onSettingsChange => _settingChanged.stream;

  /// Broadcast setting type on change
  final _settingChanged = StreamController<SettingType>.broadcast();

  /// Query a setting in box or return default
  dynamic query(SettingType type) {
    final response = _hiveBox.get(type.toString());
    if (response == null) return _defaults[type];
    return response;
  }

  /// Validate a given value before setting it as the new value
  void change(SettingType type, dynamic newValue) async {
    final isValid = _validate(type, newValue);
    if (isValid) {
      _hiveBox.put(type.toString(), newValue);
      _settingChanged.add(type);
    }
  }

  List<int> range(SettingType type) => _range[type];

  /// Private
  bool _validate(SettingType type, dynamic newValue) {
    // Within applicable ranges
    if (_range.containsKey(type)) {
      if (newValue < _range[type][0] - 1) return false;
      if (newValue > _range[type][1] + 1) return false;
    }
    // Same type
    if (newValue.runtimeType != query(type).runtimeType) return false;
    // Passed all tests
    return true;
  }

  /// Defaults
  final _range = <SettingType, dynamic>{
    SettingType.prefetch: [0, 3],
    SettingType.imageCache: [20, 200],
    SettingType.musicCache: [100, 3000],
    SettingType.mobileBitrate: [32, 320],
    SettingType.wifiBitrate: [32, 320],
  };

  final _defaults = <SettingType, dynamic>{
    SettingType.isOffline: false,
    SettingType.prefetch: 1,
    SettingType.imageCache: 80,
    SettingType.musicCache: 1000,
    SettingType.mobileBitrate: 256,
    SettingType.wifiBitrate: 320,
    SettingType.mobileOffline: false,
  };

  /// Change to offline mode when in aeroplane or similar mode
  void _onConnectivityChange(ConnectivityResult result) async {
    void onWifi() {
      final mobileOffline = query(SettingType.mobileOffline);
      if (mobileOffline) change(SettingType.isOffline, false);
    }

    void onMobile() {
      final mobileOffline = query(SettingType.mobileOffline);
      if (mobileOffline) change(SettingType.isOffline, true);
    }

    void onOffline() {
      final isOffline = query(SettingType.isOffline);
      if (!isOffline) change(SettingType.isOffline, true);
    }

    switch (result) {
      case ConnectivityResult.wifi:
        onWifi();
        break;
      case ConnectivityResult.mobile:
        onMobile();
        break;
      case ConnectivityResult.none:
        onOffline();
        break;
    }
  }

  /// Singleton boilerplate code
  static final SettingsProvider _instance = SettingsProvider._internal();

  SettingsProvider._internal() {
    Connectivity().onConnectivityChanged.listen(_onConnectivityChange);
  }

  factory SettingsProvider() => _instance;
}
