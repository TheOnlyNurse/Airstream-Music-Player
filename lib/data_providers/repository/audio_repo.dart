part of repository_library;

class _AudioRepository {
  final _provider = AudioProvider();

  ValueStream<AudioPlayerState> get playerState => _provider.playerState;

  Stream<AudioPlayerSongState> get songState => _provider.songState;

  ValueStream<Duration> get audioPosition => _provider.audioPosition;

  Duration get maxDuration => _provider.maxDuration;

  int get index => _provider.currentIndex;

  Song get current => _provider.currentSong;

  int get queueLength => _provider.songQueue.length;

  List<Song> get queue => _provider.songQueue;

  void next() => _provider.changePlayerState(ChangePlayerState.next);

  void previous() => _provider.changePlayerState(ChangePlayerState.previous);

  void pause() => _provider.changePlayerState(ChangePlayerState.pause);

  void play() => _provider.changePlayerState(ChangePlayerState.play);

  void start({@required List<Song> playlist, int index = 0}) =>
      _provider.createQueueAndPlay(playlist, index);

  void seek(double seconds) =>
      _provider.seekPosition(Duration(seconds: seconds.floor()));
}
