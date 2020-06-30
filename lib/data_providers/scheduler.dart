import 'package:airstream/barrel/provider_basics.dart';

class Scheduler {
  /// Global Variables
  Future<bool> get hasJobs async => _hasJobs();

  /// Private variables
  Box<String> get _hiveBox => Hive.box('scheduler');
  final _scheduleLocker = Mutex();

  /// Global functions
  ///
  /// Schedule jobs to be done
  Future<Null> schedule(String request) async {
    await _scheduleLocker.protect(() async {
      // If a schedule already exists, append to HiveBox
      if (await hasJobs) {
        _hiveBox.add(request);
        return;
      }
      final notAccepted = !(await ServerProvider().upload(request));
      if (notAccepted) _hiveBox.add(request);
    });
    return;
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
    for (var job in outstandingJobs) {
      final notAccepted = !(await ServerProvider().upload(job));
      if (notAccepted) _hiveBox.add(job);
    }
    // If HiveBox still has values return false, else true
    if (_hiveBox.values.isNotEmpty) return false;
    return true;
  }

  void _onStart() {
    SettingsProvider().onSettingsChange.listen((type) {
      if (type == SettingType.isOffline) _hasJobs();
    });
  }

  /// Singleton boilerplate code
  static final Scheduler _instance = Scheduler._internal();

  Scheduler._internal() {
    _onStart();
  }

  factory Scheduler() => _instance;
}
