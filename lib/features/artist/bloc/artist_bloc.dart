import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/repository/song_repository.dart';

import 'artist_event.dart';
import 'artist_state.dart';
export 'artist_event.dart';
export 'artist_state.dart';

class SingleArtistBloc extends Bloc<SingleArtistEvent, SingleArtistState> {
  SingleArtistBloc({
    @required this.albumRepository,
    @required this.artistRepository,
    @required this.songRepository,
  }) : super(SingleArtistInitial());

  final AlbumRepository albumRepository;
  final ArtistRepository artistRepository;
  final SongRepository songRepository;

  @override
  Stream<SingleArtistState> mapEventToState(SingleArtistEvent event) async* {
    final currentState = state;

    if (event is SingleArtistAlbums) {
      yield (await albumRepository.fromArtist(event.artist)).fold(
        (error) => SingleArtistFailure(error),
        (albums) => SingleArtistSuccess(event.artist, albums: albums),
      );
      if (currentState is SingleArtistSuccess) add(SingleArtistInfo());
    }

    if (event is SingleArtistInfo && currentState is SingleArtistSuccess) {
      final topSongs = (await songRepository.topSongs(
        currentState.artist,
        fallback: currentState.albums.first,
      ))
          .fold<List<Song>>((l) => [], (r) => r);
      final similar = (await artistRepository.similar(currentState.artist))
          .fold<List<Artist>>((l) => [], (r) => r);
      yield currentState.copyWith(songs: topSongs, similarArtists: similar);
    }
  }
}
