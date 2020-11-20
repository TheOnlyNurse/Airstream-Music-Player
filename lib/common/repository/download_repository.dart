import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;

import '../models/download_percentage.dart';
import '../providers/download_provider.dart';
import '../providers/moor_database.dart';
import 'song_repository.dart';

class DownloadRepository {
  DownloadRepository({
    DownloadProvider downloadManager,
    SongRepository songRepository,
  })  : _manager = downloadManager ?? _initManager(),
        _songRepository = songRepository ?? GetIt.I.get<SongRepository>();

  /// The download manager instance used by this repository.
  final DownloadProvider _manager;

  final SongRepository _songRepository;

  Stream<DownloadPercentage> get percentage => _manager.percentage;

  /// Downloads the file associated with a [Song].
  Future<Either<String, File>> download(Song song) async {
    return (await _manager.start(song)).fold(
      (error) => left(error),
      (file) async {
        return right(await _songRepository.cacheFile(song: song, file: file));
      },
    );
  }
}

/// Returns a download manager instance.
///
/// This function is dependent on GetIt. Go to the feature "loading_splash" to
/// view the GetIt implementation.
DownloadProvider _initManager() {
  final cachePath = GetIt.I.get<String>(instanceName: 'cachePath');
  return DownloadProvider(
    downloadFile: File(path.join(cachePath, 'song_file')),
  );
}
