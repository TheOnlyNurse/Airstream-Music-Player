library single_album_cubit;

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// Internal
import '../../providers/moor_database.dart';
import '../../repository/album_repository.dart';
import '../../repository/song_repository.dart';

part 'state.dart';

class SingleAlbumCubit extends Cubit<SingleAlbumState> {
  SingleAlbumCubit({this.albumRepository, this.songRepository})
      : super(SingleAlbumInitial());

  final AlbumRepository albumRepository;
  final SongRepository songRepository;

  void fetchSongs(Album album) async {
    final response = await songRepository.fromAlbum(album);
    if (response.hasData) {
      emit(SingleAlbumSuccess(album: album, songs: response.data));
    } else {
      emit(SingleAlbumError());
    }
  }

  void change(bool isStarred) async {
    var currentState = state;
    if (currentState is SingleAlbumSuccess) {
      albumRepository.updateStarred(currentState.album, isStarred);
    }
  }

  void popupSelected(int index) async {
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
  // TODO: Update album reference in dao
  // TODO: Delete album art
  // TODO: Refresh current page with a new album screen
  throw UnimplementedError();
}
