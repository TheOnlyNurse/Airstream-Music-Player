import 'dart:io';

import 'package:airstream/data_providers/repository.dart';
import 'package:bloc/bloc.dart';

abstract class AirstreamImageEvent {}

class FetchImage extends AirstreamImageEvent {
  final String coverArt;
  final bool isHiDef;

  FetchImage({this.coverArt, this.isHiDef});
}

class FetchImageBySong extends AirstreamImageEvent {
  final String songId;
  final bool isHiDef;

  FetchImageBySong({this.songId, this.isHiDef});
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
			final response = await Repository().getImage(event.coverArt, hiDef: event.isHiDef);
			switch (response.status) {
				case DataStatus.ok:
					yield ImageLoaded(image: response.data);
					break;
				default:
					yield ImageError();
			}
		}
		if (event is FetchImageBySong) {
			final response = await Repository().getSongsById([event.songId]);
			if (response.status == DataStatus.ok)
				this.add(FetchImage(
					coverArt: response.data.first.coverArt,
					isHiDef: event.isHiDef,
				));
			else
				yield ImageError();
		}
	}
}
