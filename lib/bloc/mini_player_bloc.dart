import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/mini_player_event.dart';
import 'package:airstream/states/mini_player_state.dart';

class MinimisedPlayerBloc
    extends Bloc<MinimisedPlayerEvent, MinimisedPlayerState> {
  final _repository = Repository();
  StreamSubscription _audioEvents;
  StreamSubscription _percentageSS;

  MinimisedPlayerBloc() {
    _percentageSS = _repository.download.percentageStream.listen((event) {
      if (event.songId == Repository().audio.current.id) {
        this.add(ButtonDownload(event));
      }
    });

    _audioEvents = _repository.audio.playerState.listen((state) {
      if (state == AudioPlayerState.playing) this.add(ButtonAudioPlaying());
      if (state == AudioPlayerState.paused) this.add(ButtonAudioPaused());
      if (state == AudioPlayerState.stopped) this.add(ButtonAudioStopped());
    });
  }

  @override
  MinimisedPlayerState get initialState => ButtonNoAudio();

	@override
	Stream<MinimisedPlayerState> mapEventToState(
			MinimisedPlayerEvent event) async* {
		if (event is ButtonPlayPause) {
			if (state is ButtonAudioIsPaused) {
				_repository.audio.play();
			}
			if (state is ButtonAudioIsPlaying) {
				_repository.audio.pause();
			}
		}

		// React to Audio service event calls
		if (event is ButtonDownload) {
			if (event.percentModel.hasData) {
				yield ButtonIsDownloading(percentage: event.percentModel.percentage);
			} else {
				yield ButtonFailure();
				Future.delayed(
					Duration(seconds: 2),
							() => this.add(ButtonAudioStopped()),
				);
			}
		}
		if (event is ButtonAudioStopped) {
      yield ButtonNoAudio();
    }
    if (event is ButtonAudioPaused) {
			yield ButtonAudioIsPaused();
    }
    if (event is ButtonAudioPlaying) {
      yield ButtonAudioIsPlaying();
    }
  }

  @override
  Future<void> close() {
    _audioEvents.cancel();
    _percentageSS.cancel();
    return super.close();
  }
}
