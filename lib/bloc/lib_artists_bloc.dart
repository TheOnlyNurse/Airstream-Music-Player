import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:flutter/material.dart';

class LibraryArtistsBloc extends Bloc<AlbumListEvent, AlbumListState> {
  StreamSubscription settingSS;

  LibraryArtistsBloc() {
    settingSS = Repository().settings.changed.listen((hasChanged) {
      if (hasChanged) this.add(AlbumListFetch());
    });
  }

  @override
  AlbumListState get initialState => AlbumListInitial();

  @override
  Stream<AlbumListState> mapEventToState(AlbumListEvent event) async* {
    if (event is AlbumListFetch) {
      final response = await Repository().artist.library();
      switch (response.status) {
        case DataStatus.ok:
          yield AlbumListSuccess(artists: response.data);
          break;
        case DataStatus.error:
          yield AlbumListFailure(response.message);
          break;
      }
    }
  }

  @override
  Future<void> close() {
    settingSS.cancel();
    return super.close();
  }
}

abstract class AlbumListEvent {}

class AlbumListFetch extends AlbumListEvent {}

abstract class AlbumListState {
  const AlbumListState();
}

class AlbumListInitial extends AlbumListState {}

class AlbumListFailure extends AlbumListState {
  final Widget error;

  AlbumListFailure(this.error);
}

class AlbumListSuccess extends AlbumListState {
  final List<Artist> artists;

  const AlbumListSuccess({this.artists});
}
