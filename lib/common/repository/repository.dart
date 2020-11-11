import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:moor/ffi.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;

import '../providers/settings_provider.dart';
import 'communication.dart';

part 'moor_isolate.dart';
part 'settings_repo.dart';

/// The Repository collects data from providers and formats it easy access and use
/// in UI and Bloc generation. This is the class used by the rest of the UI and bloc logic,
/// however there is little logic here. See the relevant sub-division for that.

class Repository {

  final settings = _SettingsRepository();

  /// Singleton boilerplate code
  factory Repository() => _instance;
  static final Repository _instance = Repository._internal();

  Repository._internal();
}
