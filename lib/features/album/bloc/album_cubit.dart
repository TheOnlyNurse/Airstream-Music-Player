import 'package:bloc/bloc.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/song_repository.dart';
import '../../../global_assets.dart';
import 'album_state.dart';
export 'album_state.dart';

class SingleAlbumCubit extends Cubit<SingleAlbumState> {
  SingleAlbumCubit({AlbumRepository mockAlbumRepo, SongRepository mockSongRepo})
      : _albumRepo = mockAlbumRepo ?? getIt.get<AlbumRepository>(),
        _songRepo = mockSongRepo ?? getIt.get<SongRepository>(),
        super(SingleAlbumInitial());

  final AlbumRepository _albumRepo;
  final SongRepository _songRepo;

  Future<void> fetchSongs(Album album) async {
    emit((await _songRepo.byAlbum(album)).fold(
      (error) => SingleAlbumError(error),
      (songs) => SingleAlbumSuccess(album: album, songs: songs),
    ));
  }

  void change({bool isStarred}) {
    final currentState = state;
    if (currentState is SingleAlbumSuccess) {
      _albumRepo.updateStarred(currentState.album, starred: isStarred);
    }
  }

  void popupSelected(int index) {
    switch (index) {
      case 1:
        _refreshAlbum(this);
        break;
      default:
        throw UnimplementedError("Can't map index of $index to function.");
    }
  }
}

SingleAlbumState _refreshAlbum(SingleAlbumCubit cubit) {
  throw UnimplementedError();
}
