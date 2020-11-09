part of 'repository.dart';

Future<MoorIsolate> createMoorDatabase(String dbPath) async {
  final path = p.join(dbPath, 'db.sqlite');
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startDatabase,
    _IsolateRequest(receivePort.sendPort, path),
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
