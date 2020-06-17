import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

abstract class DatabaseProvider {
  String get dbName;

  String get tableColumns;

  Database _database;
  Future<Null> _creationLocker;

  //  Open database if it hasn't been opened yet (as judged by the getter database)
  Future<Database> getDatabaseInstance() async {
    // To stop duplicate instances of databases being created concurrently
    if (_creationLocker != null) {
      await _creationLocker;
      return database;
    }

    // Lock the database creator
    var completer = new Completer<Null>();
    _creationLocker = completer.future;

    final db = await openDatabase(p.join(await getDatabasesPath(), '$dbName.db'),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE $dbName ($tableColumns)');
    });

    // Unlock the creator
    // TODO: Rewrite to get rid of locker. Creator will only ever be called once.
    completer.complete();
    _creationLocker = null;
    return db;
  }

//  On creation, create the variables below. This will return the database instance or open
//	the relevant one for use.
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }
}