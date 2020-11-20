import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';

import '../global_assets.dart';
import '../models/download_percentage.dart';
import '../repository/server_repository.dart';
import 'moor_database.dart';

class DownloadProvider {
  DownloadProvider({@required File downloadFile, ServerRepository server})
      : assert(downloadFile != null),
        _downloadFile = downloadFile,
        _server = getIt<ServerRepository>(server),
        _limiter = Mutex();

  final ServerRepository _server;

  /// A file used as to temporarily store a partially downloaded file.
  final File _downloadFile;

  /// The sink used to write bytes to the temporary download file.
  IOSink _fileSink;

  /// A subscription to a download.
  ///
  /// Used to ensure that only one song is being downloaded at any given time.
  StreamSubscription<List<int>> _downloadSubscription;

  /// Used to limit the download requests until all resources are clean/ready.
  final Mutex _limiter;

  /// See getter below.
  final _percentage = BehaviorSubject<DownloadPercentage>();

  /// Emits an ongoing download progress.
  ValueStream<DownloadPercentage> get percentage => _percentage.stream;

  /// A timer used to timeout downloads that are taking too long between data packets.
  Timer _timeoutTimer;

  /// Begin a download that might return a file if the download isn't interrupted.
  Future<Either<String, File>> start(Song song) async {
    // Interrupt any previous downloads
    if (_downloadSubscription != null) _downloadSubscription.cancel();
    await _limiter.acquire();
    _renewFile();
    final futureFile = Completer<Either<String, File>>();
    final byteStream = StreamController<List<int>>();
    // Broadcast download has begun.
    _percentage.add(DownloadPercentage(songId: song.id));

    // Retrieve the file size and pipe the bytes to [byteStream].
    return (await _server.stream('stream?id=${song.id}', byteStream)).fold(
      (error) {
        _percentage.add(_percentage.value.copyWith(isActive: false));
        return left('Streaming error.');
      },
      (size) {
        _percentage.add(_percentage.value.copyWith(total: size));
        _downloadSubscription = byteStream.stream.listen(_onData);
        byteStream.onCancel = () => _onFinished(futureFile);
        return futureFile.future;
      },
    );
  }

  /// Cancels the stream subscription which also cancels the linked controller.
  ///
  /// [_limiter] is also released here, so calling this function is vital on
  /// completion/interruption events.
  Future<void> _clean() async {
    if (_downloadSubscription != null) {
      _downloadSubscription.cancel();
      _downloadSubscription = null;
    }
    if (_limiter.isLocked) _limiter.release();
    if (_fileSink != null) _fileSink.close();
  }

  /// Prepares the download file location to receive a fresh set of bytes.
  Future<void> _renewFile() async {
    if (await _downloadFile.exists()) {
      await _downloadFile.delete();
    } else {
      await _downloadFile.create(recursive: true);
    }
    _fileSink = _downloadFile.openWrite(mode: FileMode.append);
  }

  /// Add the received bytes to the file.
  void _onData(List<int> bytes) {
    _resetTimeout();
    _fileSink.add(bytes);
    _percentage.add(_percentage.value.copyWith(increment: bytes.length));
  }

  /// Cleans up resources when the download has finished.
  ///
  /// This can be either because of an interruption or because the file is completed.
  Future<void> _onFinished(Completer<Either<String, File>> completer) async {
    await _clean();
    await _fileSink.close();
    // If the last emitted value is that a file is cached, then complete with it.
    completer.complete(_percentage.value.isCached
        ? right(_downloadFile)
        : left('Audio download was interrupted.'));
  }

  /// A timer that cancels the download stream after a set duration.
  ///
  /// Used to cancel the stream when no new information isn't given promptly.
  void _resetTimeout() {
    if (_timeoutTimer?.isActive ?? false) _timeoutTimer.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 5), () {
      if (_downloadSubscription != null) _downloadSubscription.cancel();
    });
  }
}
