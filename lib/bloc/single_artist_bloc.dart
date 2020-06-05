import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/single_artist_event.dart';
import 'package:airstream/states/single_artist_state.dart';
import 'package:bloc/bloc.dart';

class SingleArtistBloc extends Bloc<SingleArtistEvent, SingleArtistState> {
  Repository _repository = Repository();

  @override
  SingleArtistState get initialState => ArtistScreenUninitialised();

  @override
  Stream<SingleArtistState> mapEventToState(SingleArtistEvent event) async* {
    if (event is FetchArtistInfo) {
      final response = await _repository.getArtistAlbums(event.artist);
      switch (response.status) {
        case DataStatus.ok:
          yield ArtistScreenLoaded(albums: response.data);
          break;
        case DataStatus.error:
          yield ArtistScreenError();
          break;
      }
    }
  }
}
