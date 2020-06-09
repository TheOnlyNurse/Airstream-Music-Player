import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/repository.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;
import 'package:bloc/bloc.dart';

enum PlayerScreenImageEvent { fetchImage }

abstract class PlayerScreenImageState {}

class ImageUninitialised extends PlayerScreenImageState {}

class ImageError extends PlayerScreenImageState {}

class ImageLoaded extends PlayerScreenImageState {
  final File image;

  ImageLoaded({this.image});
}

class PlayerScreenImageBloc extends Bloc<PlayerScreenImageEvent, PlayerScreenImageState> {
  StreamSubscription _songChangingSS;
  final _assestAudioPlayer = assets.AssetsAudioPlayer.withId('airstream');
  final lastImages = <String, String>{};
  String _lastPlayedAudio;

  PlayerScreenImageBloc() {
    _songChangingSS = _assestAudioPlayer.current.listen((playing) {
      if (_lastPlayedAudio != playing.audio.audio.path) {
        _lastPlayedAudio = playing.audio.audio.path;
        this.add(PlayerScreenImageEvent.fetchImage);
      }
    });
  }

  @override
  PlayerScreenImageState get initialState => ImageUninitialised();

  @override
  Stream<PlayerScreenImageState> mapEventToState(PlayerScreenImageEvent event) async* {
    if (event == PlayerScreenImageEvent.fetchImage) {
      final currentSong = Repository().currentSong;
      if (lastImages.isNotEmpty && lastImages.keys.contains(currentSong.coverArt)) {
        yield ImageLoaded(image: File(lastImages[currentSong.coverArt]));
      } else {
        final response = await Repository().getImage(currentSong.coverArt, hiDef: true);
        switch (response.status) {
          case DataStatus.ok:
            lastImages[currentSong.coverArt] = response.data.path;
            yield ImageLoaded(image: response.data);
            break;
          default:
            yield ImageError();
        }
      }
    }
  }

  @override
  Future<void> close() {
    _songChangingSS.cancel();
    return super.close();
  }
}
