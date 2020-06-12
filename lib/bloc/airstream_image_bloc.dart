import 'dart:io';

import 'package:airstream/data_providers/repository.dart';
import 'package:bloc/bloc.dart';

abstract class AirstreamImageEvent {}

class FetchImage extends AirstreamImageEvent {
  final String coverArt;
  final int songId;
  final bool isHiDef;

  FetchImage({this.songId, this.coverArt, this.isHiDef});
}

abstract class AirstreamImageState {}

class ImageUninitialised extends AirstreamImageState {}

class ImageError extends AirstreamImageState {}

class ImageLoaded extends AirstreamImageState {
  final File image;

  ImageLoaded({this.image});
}

class AirstreamImageBloc extends Bloc<AirstreamImageEvent, AirstreamImageState> {
  @override
  AirstreamImageState get initialState => ImageUninitialised();

  @override
  Stream<AirstreamImageState> mapEventToState(AirstreamImageEvent event) async* {
		if (event is FetchImage) {
			RepoResponse response;
			if (event.coverArt != null)
				response =
				await Repository().getImage(artId: event.coverArt, hiDef: event.isHiDef);
			if (event.songId != null)
				response =
				await Repository().getImage(songId: event.songId, hiDef: event.isHiDef);
			switch (response.status) {
				case DataStatus.ok:
					yield ImageLoaded(image: response.data);
					break;
				default:
					yield ImageError();
			}
		}
	}
}
