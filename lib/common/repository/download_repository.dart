import 'dart:async';
import 'dart:io';

import 'package:airstream/common/models/download_percentage.dart';
import 'package:airstream/common/providers/download_provider.dart';
import 'package:airstream/common/providers/moor_database.dart';
import 'package:airstream/common/repository/song_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;

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
  Future<File> download(Song song) async {
    final file = await _manager.start(song);
    if (file != null) {
      return _songRepository.cacheFile(song: song, file: file);
    } else {
      return null;
    }
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
