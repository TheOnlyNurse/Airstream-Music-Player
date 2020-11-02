import 'dart:async';


import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Internal links
import '../repository/artist_repository.dart';
import '../complex_widgets/error_widgets.dart';
import '../events/single_artist_event.dart';
import '../repository/album_repository.dart';
import '../states/single_artist_state.dart';
import '../repository/song_repository.dart';

// Barrelling
export '../states/single_artist_state.dart';
export '../events/single_artist_event.dart';

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
      final response = await albumRepository.fromArtist(event.artist);
      if (response.hasData) {
        yield SingleArtistSuccess(event.artist, albums: response.data);
        this.add(SingleArtistInfo());
      } else {
        yield SingleArtistFailure(ErrorText(error: response.error));
      }
    }

    if (event is SingleArtistInfo && currentState is SingleArtistSuccess) {
      final topSongs = await songRepository.topSongsOf(currentState.artist);
      final similar = await artistRepository.similar(currentState.artist);
      yield currentState.copyWith(
        songs: topSongs.data,
        similarArtists: similar.data,
      );
    }
  }
}
