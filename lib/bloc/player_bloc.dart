
import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/player_events.dart';
import 'package:airstream/states/player_state.dart';
export 'package:airstream/events/player_events.dart';
export 'package:airstream/states/player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final _repository = Repository();

  StreamSubscription _newSong;
  StreamSubscription _audioStopped;

  PlayerBloc() {
    _newSong = _repository.audio.songState.listen((state) {
      if (state == AudioPlayerSongState.newSong) {
        this.add(PlayerFetch());
      }
    });
    _audioStopped = _repository.audio.playerState.listen((state) {
      if (state == AudioPlayerState.stopped) {
        this.add(PlayerStopped());
      }
    });
  }

  @override
  PlayerState get initialState => PlayerInitial(_repository.audio.current);

  @override
  Stream<PlayerState> mapEventToState(PlayerEvent event) async* {
    final currentState = state;

    if (event is PlayerFetch) {
      final song = _repository.audio.current;
      final response = await Repository().album.fromSong(song);
      if (response.hasData) {
        yield PlayerSuccess(song: song, album: response.album);
        this.add(PlayerFetchArt(song.art));
      }
    }

    if (event is PlayerFetchArt) {
      final response = await _repository.image.original(event.artId);
      if (response != null && currentState is PlayerSuccess) {
        yield currentState.copyWith(image: response);
      }
    }

    if (event is PlayerStopped) {
      yield PlayerSuccess(song: _repository.audio.current, isFinished: true);
    }
  }

  @override
  Future<void> close() {
    _audioStopped.cancel();
    _newSong.cancel();
    return super.close();
  }
}
