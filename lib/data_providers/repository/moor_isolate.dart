part of repository_library;

Future<MoorIsolate> _createMoorDatabase(String dbPath) async {
  final path = p.join(dbPath, 'db.sqlite');
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startDatabase,
    _IsolateRequest(receivePort.sendPort, path),
  );
  return (await receivePort.first as MoorIsolate);
}

// ignore: missing_return
DatabaseConnection _startDatabase(_IsolateRequest request) {
  final executor = VmDatabase(File(request.path), logStatements: false);
  final moorIsolate = MoorIsolate.inCurrent(
    () => DatabaseConnection.fromExecutor(executor),
  );
  request.sendPort.send(moorIsolate);
}

Future<MoorIsolate> _createMoorCache() async {
  final dbFolder = await getTemporaryDirectory();
  final path = p.join(dbFolder.path, 'db.sqlite');
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _startCache,
    _IsolateRequest(receivePort.sendPort, path),
  );
  return (await receivePort.first as MoorIsolate);
}

// ignore: missing_return
DatabaseConnection _startCache(_IsolateRequest request) {
	final executor = VmDatabase(File(request.path), logStatements: false);
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
