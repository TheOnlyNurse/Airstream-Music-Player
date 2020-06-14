import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class Scheduler {
  /// Global Variables
  Future<bool> get hasJobs async => !(await _checkSchedule());

  /// Private variables
  Future<File> get _scheduleFile async =>
      File(p.join(await getDatabasesPath(), 'schedule.json'));

  /// Global functions
  ///
  /// Schedule jobs to be done
  /// Appends the request to the current schedule list if it exists.
  /// Attempts to complete the job if it doesn't.
  /// If the job is a failure, creates a new schedule.
  Future<Null> schedule(String request) async {
    final scheduleFile = await _scheduleFile;
    // If a schedule already exists, append the current request to it
    if (scheduleFile.existsSync()) {
      final json = scheduleFile.readAsStringSync();
      final List<String> currentSchedule = jsonDecode(json).cast<String>();
      currentSchedule.add(request);
      return;
    }

    final isAccepted = await ServerProvider().upload(request);
    if (isAccepted) {
      print('upload success!');
      return;
    } else {
      // Since the request wasn't accepted, start a new schedule
      scheduleFile.createSync(recursive: true);
      scheduleFile.writeAsStringSync(jsonEncode([request]));
    }
  }

  /// Private Functions
  ///
  /// Returns true once all scheduled jobs are complete.
  /// Also  tries to complete pending jobs.
  void _onStart() {
    SettingsProvider().isOfflineChanged.stream.listen((hasChanged) {
      if (hasChanged) _checkSchedule();
    });
  }

  Future<bool> _checkSchedule() async {
    final noFile = !(await _scheduleFile).existsSync();
    // If there is no scheduler file, there aren't any pending jobs
    if (noFile) return true;

    final schedule = jsonDecode((await _scheduleFile).readAsStringSync()).cast<String>();
    (await _scheduleFile).deleteSync();
    final jobsCompleted = await _completeJobs(schedule);
    return jobsCompleted ? true : false;
  }

  /// Completes pending jobs when given the associated list
  Future<bool> _completeJobs(List<String> schedule) async {
    print('Starting jobs');
    final newSchedule = <String>[];

    for (var job in schedule) {
      final isNotAccepted = !(await ServerProvider().upload(job));
      if (isNotAccepted) newSchedule.add(job);
    }

    if (newSchedule.isNotEmpty) {
      print('schedule: $newSchedule');
      final scheduleFile = await _scheduleFile;
      scheduleFile.createSync(recursive: true);
      scheduleFile.writeAsStringSync(jsonEncode(newSchedule));
      return false;
    } else {
      print('upload success!');
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
