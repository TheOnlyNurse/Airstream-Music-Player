import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';

class SingleArtistBloc extends Bloc<SingleArtistEvent, SingleArtistState> {
  @override
  SingleArtistState get initialState => SingleArtistInitial();

  @override
  Stream<SingleArtistState> mapEventToState(SingleArtistEvent event) async* {
    if (event is SingleArtistFetch) {
      final response = await Repository().album.fromArtist(event.artist);
      switch (response.status) {
        case DataStatus.ok:
          yield SingleArtistSuccess(albums: response.data);
          break;
        case DataStatus.error:
          yield SingleArtistFailure();
          break;
      }
    }
  }
}

abstract class SingleArtistEvent {}

class SingleArtistFetch extends SingleArtistEvent {
  final Artist artist;

  SingleArtistFetch({this.artist});
}

abstract class SingleArtistState {}

class SingleArtistInitial extends SingleArtistState {}

class SingleArtistSuccess extends SingleArtistState {
  final List<Album> albums;

  SingleArtistSuccess({this.albums});
}

class SingleArtistFailure extends SingleArtistState {}
