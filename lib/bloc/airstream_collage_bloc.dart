import 'dart:io';
import 'package:airstream/data_providers/repository.dart';
import 'package:bloc/bloc.dart';

abstract class AirstreamCollageEvent {}

class FetchCollage extends AirstreamCollageEvent {
  final List<String> artistIdList;

  FetchCollage(this.artistIdList);
}

abstract class AirstreamCollageState {}

class CollageUninitialised extends AirstreamCollageState {}

class CollageError extends AirstreamCollageState {}

class CollageLoaded extends AirstreamCollageState {
  final List<File> imageList;

  CollageLoaded(this.imageList);
}

class AirstreamCollageBloc extends Bloc<AirstreamCollageEvent, AirstreamCollageState> {
  @override
  AirstreamCollageState get initialState => CollageUninitialised();

  @override
  Stream<AirstreamCollageState> mapEventToState(AirstreamCollageEvent event) async* {
    if (event is FetchCollage) {
      final response = await Repository().getSongsById(event.artistIdList);
      if (response.status == DataStatus.ok) {
        final List<File> artList = [];
        for (var songs in response.data) {
          final art = await Repository().getImage(songs.coverArt);
          if (art.status == DataStatus.ok) {
            artList.add(art.data);
          }
        }
        yield CollageLoaded(artList);
      } else {
        yield CollageError();
      }
    }
  }
}
