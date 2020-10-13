import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/repository/artist_repository.dart';
import 'package:airstream/widgets/error_widgets.dart';
import 'package:flutter/material.dart';

class LibraryArtistsBloc extends Bloc<AlbumListEvent, AlbumListState> {
  LibraryArtistsBloc({this.artistRepository}) : super(AlbumListInitial()) {
    _onNetworkChange = _repository.settings.onChange.listen((type) {
      if (type == SettingType.isOffline) this.add(AlbumListFetch());
    });
  }

  final _repository = Repository();
  final ArtistRepository artistRepository;
  StreamSubscription _onNetworkChange;

  @override
  Stream<AlbumListState> mapEventToState(AlbumListEvent event) async* {
    if (event is AlbumListFetch) {
			final response = await artistRepository.byAlphabet();
      if (response.hasData) {
        yield AlbumListSuccess(artists: response.data);
      } else {
        yield AlbumListFailure(ErrorText(error: response.error));
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
