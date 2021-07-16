import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/repository/song_repository.dart';
import '../../../global_assets.dart';
import 'artist_state.dart';

export 'artist_state.dart';

class ArtistCubit extends Cubit<ArtistState> {
  ArtistCubit({
    AlbumRepository mockAlbumRepo,
    ArtistRepository mockArtistRepo,
    SongRepository mockSongRepo,
  })  : _albumRepo = mockAlbumRepo ?? getIt.get<AlbumRepository>(),
        _artistRepo = mockArtistRepo ?? getIt.get<ArtistRepository>(),
        _songRepo = mockSongRepo ?? getIt.get<SongRepository>(),
        super(SingleArtistInitial());

  final AlbumRepository _albumRepo;
  final ArtistRepository _artistRepo;
  final SongRepository _songRepo;

  Future<void> fetch(Artist artist) async {
    emit((await _albumRepo.fromArtist(artist)).fold(
      (error) => SingleArtistFailure(error),
      (albums) => SingleArtistSuccess(artist, albums: albums),
    ));

    final currentState = state;

    if (currentState is SingleArtistSuccess) {
      final topSongs = (await _songRepo.topSongs(
        currentState.artist,
        fallback: currentState.albums.first,
      ))
          .fold<List<Song>>((l) => [], (r) => r);
      final similar = (await _artistRepo.similar(currentState.artist))
          .fold<List<Artist>>((l) => [], (r) => r);
      emit(currentState.copyWith(songs: topSongs, similarArtists: similar));
    }
  }
}
