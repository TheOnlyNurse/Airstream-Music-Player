import 'package:hive/hive.dart';
import 'package:mutex/mutex.dart';

import '../../global_assets.dart';
import '../repository/server_repository.dart';
import '../repository/settings_repository.dart';

class Scheduler {
  Scheduler({ServerRepository server, SettingsRepository settings, Box hive})
      : _server = getIt<ServerRepository>(server),
        _settings = getIt<SettingsRepository>(settings),
        _hive = hive ?? Hive.box<String>('scheduler') {
    _onConnectivityChange();
  }

  final ServerRepository _server;
  final SettingsRepository _settings;
  final Box _hive;

  /// Attempts to complete pending uploads and returns whether it was successful.
  Future<bool> get hasJobs async => !(await _completeJobs());

  final _scheduleLocker = Mutex();


  /// Schedule jobs to be done.
  Future<void> schedule(String request) async {
    return _scheduleLocker.protect(() async {
      // If a schedule already exists, append to it.
      if (await hasJobs) {
        _hive.add(request);
      } else {
        final notAccepted = !(await _server.upload(request));
        if (notAccepted) _hive.add(request);
      }
    });
  }

  /// Completes pending upload jobs.
  ///
  /// Returns true if there are no jobs pending and false otherwise.
  Future<bool> _completeJobs() async {
    if (_hive.values.isEmpty) return true;
    // Get jobs and clear box
    final outstandingJobs = _hive.values as List<String>;
    _hive.clear();
    // Add undone jobs back into box
    for (final job in outstandingJobs) {
      final notAccepted = !(await _server.upload(job));
      if (notAccepted) _hive.add(job);
    }
    // Empty means there are no jobs pending.
    return _hive.values.isEmpty;
  }

  void _onConnectivityChange() {
    _settings.connectivityChanged.listen((isOnline) {
      if (isOnline) _completeJobs();
    });
  }
}
