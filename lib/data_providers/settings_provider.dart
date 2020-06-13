import 'dart:convert';
import 'dart:io';
import 'package:airstream/data_providers/repository.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SettingsProvider {
  static final SettingsProvider _instance = SettingsProvider._internal();

  SettingsProvider._internal() {
    print("SettingsProvider initialised.");
  }

  factory SettingsProvider() => _instance;

  final _cache = <String, dynamic>{};

  Future<int> get prefetchValue async =>
      _cache['prefetchValue'] ?? await _getFromFile('prefetchValue');

  Future<bool> get isOffline async =>
      _cache['isOffline'] ?? await _getFromFile('isOffline');

  Future<int> get musicCacheSize async =>
      _cache['musicCacheSize'] ?? await _getFromFile('musicCacheSize');

  Future<int> get imageCacheSize async =>
      _cache['imageCacheSize'] ?? await _getFromFile('imageCacheSize');

  Future<dynamic> _getFromFile(cacheKey) async {
    final file = File(p.join(await getDatabasesPath(), 'settings.json'));

    if (file.existsSync()) {
      _cache.addAll(jsonDecode(file.readAsStringSync()));
      return _cache[cacheKey];
    } else {
      file.createSync(recursive: true);
      final defaults = {
        'prefetchValue': 1,
        'isOffline': false,
        'musicCacheSize': 100,
        'imageCacheSize': 20,
      };
      file.writeAsStringSync(jsonEncode(defaults));
      _cache.addAll(defaults);
      return defaults[cacheKey];
    }
  }

  Future<Null> setSetting(SettingsChangedType type, dynamic value) async {
    switch (type) {
      case SettingsChangedType.prefetch:
        if (value > -1 && value < 4) {
          _cache['prefetchValue'] = value as int;
        }
        break;
      case SettingsChangedType.isOffline:
        _cache['isOffline'] = value as bool;
        break;
      case SettingsChangedType.imageCache:
        if (value > 20 && value < 1000) {
          _cache['imageCacheSize'] = value as int;
        }
        break;
      case SettingsChangedType.musicCache:
        if (value > 99) {
          _cache['musicCacheSize'] = value as int;
        }
        break;
    }
    final file = File(p.join(await getDatabasesPath(), 'settings.json'));
    file.writeAsStringSync(jsonEncode(_cache));
    return;
  }
}

enum SettingsChangedType { prefetch, isOffline, imageCache, musicCache }