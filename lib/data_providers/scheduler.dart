import 'dart:convert';
import 'package:airstream/barrel/provider_basics.dart';
import 'package:path/path.dart' as p;

class Scheduler {
  /// Global Variables
  Future<bool> get hasJobs async => !(await _checkSchedule());

  /// Private variables
  Future<File> get _scheduleFile async =>
      File(p.join(await getDatabasesPath(), 'schedule.json'));
  Future<Null> _uploadingLocker;
  Future<Null> _scheduleLocker;

  /// Global functions
  ///
  /// Schedule jobs to be done
  /// Appends the request to the current schedule list if it exists.
  /// Attempts to complete the job if it doesn't.
  /// If the job is a failure, creates a new schedule.
  Future<Null> schedule(String request) async {
    if (_scheduleLocker != null) {
      await _scheduleLocker;
      return schedule(request);
    }

    // Lock the database creator
    var completer = new Completer<Null>();
    _scheduleLocker = completer.future;

    final scheduleFile = await _scheduleFile;
    // If a schedule already exists, append the current request to it
    if (await hasJobs) {
      final json = scheduleFile.readAsStringSync();
      final List<String> currentSchedule = jsonDecode(json).cast<String>();
      currentSchedule.add(request);
      scheduleFile.writeAsStringSync(jsonEncode(currentSchedule));
      return;
    }

    final notAccepted = !(await _upload(request));

    if (notAccepted) {
      // Since the request wasn't accepted, start a new schedule
      scheduleFile.createSync(recursive: true);
      scheduleFile.writeAsStringSync(jsonEncode([request]));
    }

    completer.complete();
    _scheduleLocker = null;
    return;
  }

  /// Private Functions
  ///
  /// Returns true once all scheduled jobs are complete.
  /// Also  tries to complete pending jobs.

  Future<bool> _upload(request) async {
    if (_uploadingLocker != null) {
      await _uploadingLocker;
      return _upload(request);
    }

    // Lock the database creator
    var completer = new Completer<Null>();
    _uploadingLocker = completer.future;

    final hasUploaded = await ServerProvider().upload(request);

    await Future.delayed(Duration(milliseconds: 500));
    completer.complete();
    _uploadingLocker = null;
    return hasUploaded;
  }

  void _onStart() {
    SettingsProvider().isOfflineChanged.stream.listen((hasChanged) {
      if (hasChanged) _checkSchedule();
    });
  }

  Future<bool> _checkSchedule() async {
    final file = await _scheduleFile;
    final noFile = !file.existsSync();
    // If there is no scheduler file, there aren't any pending jobs
    if (noFile) return true;

    final schedule = jsonDecode(file.readAsStringSync()).cast<String>();
    file.deleteSync();
    final jobsCompleted = await _completeJobs(schedule);
    return jobsCompleted ? true : false;
  }

  /// Completes pending jobs when given the associated list
  Future<bool> _completeJobs(List<String> schedule) async {
    final newSchedule = <String>[];

    for (var job in schedule) {
      final isNotAccepted = !(await _upload(job));
      if (isNotAccepted) newSchedule.add(job);
    }

    if (newSchedule.isNotEmpty) {
      final scheduleFile = await _scheduleFile;
      scheduleFile.createSync(recursive: true);
      scheduleFile.writeAsStringSync(jsonEncode(newSchedule));
      return false;
    } else {
      return true;
    }
  }

  /// Singleton boilerplate code
  static final Scheduler _instance = Scheduler._internal();

  Scheduler._internal() {
    _onStart();
  }

  factory Scheduler() => _instance;
}
