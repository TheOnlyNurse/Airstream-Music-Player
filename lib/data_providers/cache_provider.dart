import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract class CacheProvider {
  String get dbName;

  String get tableColumns;

  Future<String> get cacheLocation async =>
      p.join((await getTemporaryDirectory()).path, '$dbName/');

  Database _database;
  Future<Null> _creationLocker;

  final Uuid idGenerator = Uuid();

  // Dart reads files in bytes.
  int get maxCacheSize;

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

    print('Opening database instance for $dbName.');
    final db = await openDatabase(p.join(await cacheLocation, '$dbName.db'), version: 1,
        onCreate: (Database db, int version) async {
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

  // Used to stop multiple check cache (and thus delete) method calls from firing concurrently
  Future<Null> _cacheLocker;

  Future checkCacheSize() async {
    // Check if cache is already being checked
    if (_cacheLocker != null) {
      await _cacheLocker;
      return checkCacheSize();
    }

    // Lock the cache from being deleted
    var completer = new Completer<Null>();
    _cacheLocker = completer.future;

    // Get the stats of the cache directory
    final db = await database;
    var rawQuery = await db.rawQuery('SELECT size FROM $dbName');
    final cacheSize = rawQuery.fold(0, (prev, curr) => prev + curr.values.first);
    // Standardise the cache size and compare
    if (cacheSize > maxCacheSize) {
      // Get the rowId => location of file => delete file => delete database entry
      var rawQuery =
          await db.rawQuery('SELECT location FROM $dbName ORDER BY ROWID ASC LIMIT 1');
      final fileLocation = rawQuery.first.values.first;
      final File cachedFile = File(fileLocation);
      if (await cachedFile.exists()) cachedFile.delete();
      await db.rawDelete('DELETE FROM $dbName WHERE location="$fileLocation"');
    }

    // Unlock resources
    completer.complete();
    _cacheLocker = null;
  }
}
