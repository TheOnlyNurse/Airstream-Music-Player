import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:meta/meta.dart';
import 'package:moor/ffi.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../../models/percentage_model.dart';
import '../../repository/communication.dart';
import '../audio_provider.dart';
import '../download_provider.dart';
import '../moor_database.dart';
import '../settings_provider.dart';

part 'audio_repo.dart';

part 'download_repo.dart';

part 'moor_isolate.dart';

part 'settings_repo.dart';

/// The Repository collects data from providers and formats it easy access and use
/// in UI and Bloc generation. This is the class used by the rest of the UI and bloc logic,
/// however there is little logic here. See the relevant sub-division for that.

class Repository {
  /// Libraries
  final audio = _AudioRepository();

  final settings = _SettingsRepository();

  final download = _DownloadRepository();

  /// Singleton boilerplate code
  factory Repository() => _instance;
  static final Repository _instance = Repository._internal();

  Repository._internal();
}
