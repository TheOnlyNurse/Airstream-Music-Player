import 'package:airstream/common/global_assets.dart';
import 'package:airstream/common/repository/server_repository.dart';
import 'package:airstream/common/repository/settings_repository.dart';
import 'package:hive/hive.dart';
import 'package:mutex/mutex.dart';

class Scheduler {
  final ServerRepository _server;
  final SettingsRepository _settings;

  Future<bool> get hasJobs async => _hasJobs();

  /// Private variables
  Box<String> get _hiveBox => Hive.box('scheduler');
  final _scheduleLocker = Mutex();

  /// Global functions
  ///
  /// Schedule jobs to be done
  Future<void> schedule(String request) async {
    return _scheduleLocker.protect(() async {
      // If a schedule already exists, append to HiveBox
      if (await hasJobs) {
        _hiveBox.add(request);
        return;
      }
      final notAccepted = !(await _server.upload(request));
      if (notAccepted) _hiveBox.add(request);
    });
  }

  /// Private Functions

  /// Checks schedule
  /// Returns true if there are jobs pending
  /// Returns false if there are no jobs pending
  Future<bool> _hasJobs() async {
    if (_hiveBox.values.isEmpty) return false;
    // Get jobs and clear box
    final outstandingJobs = _hiveBox.values;
    _hiveBox.clear();
    // Add undone jobs back into box
    for (final job in outstandingJobs) {
      final notAccepted = !(await _server.upload(job));
      if (notAccepted) _hiveBox.add(job);
    }
    // If HiveBox still has values return false, else true
    if (_hiveBox.values.isNotEmpty) return false;
    return true;
  }

  void _onStart() {
    _settings.connectivityChanged.listen((isOnline) {
      if (isOnline) _hasJobs();
    });
  }

  /// Singleton boilerplate code
  factory Scheduler() => _instance;
  static final Scheduler _instance = Scheduler._internal();

  Scheduler._internal({ServerRepository server, SettingsRepository settings})
      : _server = getIt<ServerRepository>(server),
        _settings = getIt<SettingsRepository>(settings) {
    _onStart();
  }
}
