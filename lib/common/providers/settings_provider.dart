import 'package:meta/meta.dart';
import 'package:hive/hive.dart';

class SettingsProvider {
  SettingsProvider({@required Box hive})
      : assert(hive != null),
        _hive = hive;

  /// Hive box used as persistent storage.
  final Box _hive;

  /// Query a setting in box or return default
  T query<T>(SettingType type) {
    final response = _hive.get(type.index) as T;
    return response ?? _Static.defaults[type] as T;
  }

  /// Validate a given value before setting it as the new value
  void change<T>(SettingType type, T newValue) {
    assert(T == query<T>(type).runtimeType);
    if (_Static.range.containsKey(type)) {
      assert(newValue as int > _Static.range[type].first - 1);
      assert(newValue as int < _Static.range[type].last + 1);
    }

    _hive.put(type.index, newValue);
  }

  List<int> range(SettingType type) => _Static.range[type];
}

class _Static {
  // This class is not meant to be instantiated or extended.
  // ignore: unused_element
  _Static._();

  static const defaults = <SettingType, dynamic>{
    SettingType.isOnline: true,
    SettingType.autoOffline: false,
    SettingType.prefetch: 1,
    SettingType.imageCache: 80,
    SettingType.musicCache: 1000,
    SettingType.mobileBitrate: 256,
    SettingType.wifiBitrate: 320,
  };

  /// Permitted range for defaults.
  static const range = <SettingType, List<int>>{
    SettingType.prefetch: [0, 3],
    SettingType.imageCache: [20, 200],
    SettingType.musicCache: [100, 3000],
    SettingType.mobileBitrate: [128, 320],
    SettingType.wifiBitrate: [128, 320],
  };
}

enum SettingType {
  isOnline,
  autoOffline,
  prefetch,
  imageCache,
  musicCache,
  wifiBitrate,
  mobileBitrate,
}
