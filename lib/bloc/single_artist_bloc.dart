import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/events/single_artist_event.dart';
import 'package:airstream/repository/album_repository.dart';
import 'package:airstream/repository/artist_repository.dart';
import 'package:airstream/states/single_artist_state.dart';
import 'package:airstream/widgets/error_widgets.dart';

// Barrelling
export 'package:airstream/states/single_artist_state.dart';
export 'package:airstream/events/single_artist_event.dart';

class SingleArtistBloc extends Bloc<SingleArtistEvent, SingleArtistState> {
  SingleArtistBloc(
      {this.albumRepository, this.artistRepository})
      : super(SingleArtistInitial());

  final AlbumRepository albumRepository;
  final ArtistRepository artistRepository;
  final _repo = Repository();

  @override
  Stream<SingleArtistState> mapEventToState(SingleArtistEvent event) async* {
    final currentState = state;

    if (event is SingleArtistAlbums) {
      final response = await albumRepository.fromArtist(event.artist);
      if (response.hasData) {
        yield SingleArtistSuccess(event.artist, albums: response.data);
        this.add(SingleArtistInfo());
      } else {
        yield SingleArtistFailure(ErrorText(error: response.error));
      }
    }

    if (event is SingleArtistInfo && currentState is SingleArtistSuccess) {
      final topSongs = await _repo.song.topSongsOf(currentState.artist);
      final similar = await artistRepository.similar(currentState.artist);
      yield currentState.copyWith(
        songs: topSongs.songs,
        similarArtists: similar.data,
      );
    }
  }
}
