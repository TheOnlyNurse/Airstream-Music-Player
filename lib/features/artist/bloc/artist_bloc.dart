import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../common/models/repository_response.dart';
import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/repository/song_repository.dart';

part 'artist_event.dart';
part 'artist_state.dart';

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
        add(SingleArtistInfo());
      } else {
        yield SingleArtistFailure(response);
      }
    }

    if (event is SingleArtistInfo && currentState is SingleArtistSuccess) {
      final topSongs = await songRepository.topSongs(
        currentState.artist,
        fallback: currentState.albums.first,
      );
      final similar = await artistRepository.similar(currentState.artist);
      yield currentState.copyWith(
        songs: topSongs.data,
        similarArtists: similar.data,
      );
    }
  }
}
