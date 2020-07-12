import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/single_artist_event.dart';
import 'package:airstream/states/single_artist_state.dart';

// Barrelling
export 'package:airstream/states/single_artist_state.dart';
export 'package:airstream/events/single_artist_event.dart';

class SingleArtistBloc extends Bloc<SingleArtistEvent, SingleArtistState> {
  final _repo = Repository();

  @override
  SingleArtistState get initialState => SingleArtistInitial();

  @override
  Stream<SingleArtistState> mapEventToState(SingleArtistEvent event) async* {
    final currentState = state;

    if (event is SingleArtistAlbums) {
      final response = await _repo.album.fromArtist(event.artist);
      if (response.hasData) {
        yield SingleArtistSuccess(event.artist, albums: response.albums);
        this.add(SingleArtistInfo());
      } else {
        yield SingleArtistFailure(response.error);
      }
    }

    if (event is SingleArtistInfo && currentState is SingleArtistSuccess) {
      final topSongs = await _repo.song.topSongsOf(currentState.artist);
      final similar = await _repo.artist.similar(currentState.artist);
      final image = await _repo.image.fromArtist(currentState.artist);
      yield currentState.copyWith(
        songs: topSongs.songs,
        similarArtists: similar.artists,
        image: image,
      );
    }
  }
}
