import 'dart:io';
import 'dart:isolate';
import 'package:moor/ffi.dart';
import 'package:moor/moor.dart';
import 'package:path/path.dart' as path;
import 'package:moor/isolate.dart';

Future<MoorIsolate> createMoorDatabase(String dbPath) async {
  final database = path.join(dbPath, 'db.sqlite');
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startDatabase,
    _IsolateRequest(receivePort.sendPort, database),
  );
  return await receivePort.first as MoorIsolate;
}

void _startDatabase(_IsolateRequest request) {
  // Add "logStatements: true" to add logging support.
  final executor = VmDatabase(File(request.path));
  final moorIsolate = MoorIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(executor),
  );
  request.sendPort.send(moorIsolate);
}

/// Used to communicate between isolates and the main thread
class _IsolateRequest {
  final SendPort sendPort;
  final String path;

  const _IsolateRequest(this.sendPort, this.path);
}
