import 'dart:async';
import 'dart:io';
import 'package:airstream/data_providers/repository.dart';
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
  final _player = Repository().audioPlayer;
  final lastImages = <String, String>{};
  String _lastPlayedAudio;

  PlayerScreenImageBloc() {
    _songChangingSS = _player.current.listen((playing) {
      if (playing != null && _lastPlayedAudio != playing.audio.audio.path) {
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
      if (lastImages.isNotEmpty && lastImages.keys.contains(currentSong.art)) {
        yield ImageLoaded(image: File(lastImages[currentSong.art]));
      } else {
        final response = await Repository().getImage(artId: currentSong.art, hiDef: true);
        switch (response.status) {
          case DataStatus.ok:
            lastImages[currentSong.art] = response.data.path;
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
