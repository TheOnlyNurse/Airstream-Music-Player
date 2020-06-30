import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:flutter/material.dart';

class LibraryArtistsBloc extends Bloc<AlbumListEvent, AlbumListState> {
  final _repository = Repository();
  StreamSubscription _onNetworkChange;

  LibraryArtistsBloc() {
    _onNetworkChange = _repository.settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(AlbumListFetch());
    });
  }

  @override
  AlbumListState get initialState => AlbumListInitial();

  @override
  Stream<AlbumListState> mapEventToState(AlbumListEvent event) async* {
    if (event is AlbumListFetch) {
			final response = await _repository.artist.byAlphabet();
      if (response.hasData) {
        yield AlbumListSuccess(artists: response.artists);
      } else {
        yield AlbumListFailure(response.message);
      }
    }
  }

  @override
  Future<void> close() {
    _onNetworkChange.cancel();
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
