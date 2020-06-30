part of repository_library;

class _DownloadRepository {
  /// Private
  final _provider = DownloadProvider();

  /// Global variables
  Stream<PercentageModel> get percentageStream => _provider.percentageStream;

  Stream<Song> get newPlayableSong => _provider.songPlayable;
}
