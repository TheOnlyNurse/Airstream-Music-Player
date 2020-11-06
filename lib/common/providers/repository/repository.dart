import 'dart:io';
import 'dart:isolate';

/// External Packages
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:moor/isolate.dart';
import 'package:moor/moor.dart';
import 'package:moor/ffi.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;

import '../audio_provider.dart';
import '../download_provider.dart';
import '../moor_database.dart';
import '../playlist_provider.dart';
import '../scheduler.dart';
import '../settings_provider.dart';

/// Models
import '../../models/playlist_model.dart';
import '../../models/response/playlist_response.dart';
import '../../repository/communication.dart';
import '../../models/percentage_model.dart';

/// Parts
part 'audio_repo.dart';

part 'playlist_repo.dart';

part 'settings_repo.dart';

part 'download_repo.dart';

part 'moor_isolate.dart';

/// The Repository collects data from common.providers and formats it easy access and use
/// in UI and Bloc generation. This is the class used by the rest of the UI and common.bloc logic,
/// however there is little logic here. See the relevant sub-division for that.

class Repository {

  /// Libraries
  final audio = _AudioRepository();

  final playlist = _PlaylistRepository();

  final settings = _SettingsRepository();

  final download = _DownloadRepository();

  /// Singleton boilerplate code
  static final Repository _instance = Repository._internal();

  Repository._internal();

  factory Repository() => _instance;
}
