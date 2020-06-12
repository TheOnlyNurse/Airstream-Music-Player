import 'dart:io';
import 'package:airstream/data_providers/repository.dart';
import 'package:bloc/bloc.dart';

abstract class AirstreamCollageEvent {}

class FetchCollage extends AirstreamCollageEvent {
  final List<int> songIdList;

  FetchCollage(this.songIdList);
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
      final List<File> artList = [];
      for (var id in event.songIdList) {
        final art = await Repository().getImage(songId: id);
        if (art.status == DataStatus.ok) {
          artList.add(art.data);
        }
      }
      yield CollageLoaded(artList);
    }
  }
}
