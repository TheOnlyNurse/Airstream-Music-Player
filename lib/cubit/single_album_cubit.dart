import 'package:airstream/repository/album_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
/// Internal
import '../data_providers/moor_database.dart';
import '../data_providers/repository/repository.dart';

class SingleAlbumCubit extends Cubit<SingleAlbumState> {
  SingleAlbumCubit({@required this.albumRepository})
      : assert(albumRepository != null),
        super(SingleAlbumInitial());

  final AlbumRepository albumRepository;

  void fetchSongs(Album album) async {
    final response = await Repository().song.fromAlbum(album);
    if (response.hasData) {
      emit(SingleAlbumSuccess(album: album, songs: response.songs));
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
    switch(index) {
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

abstract class SingleAlbumState extends Equatable {
  const SingleAlbumState();

  @override
  List<Object> get props => [];
}

class SingleAlbumInitial extends SingleAlbumState {}

class SingleAlbumSuccess extends SingleAlbumState {
  const SingleAlbumSuccess({this.album, this.songs});

  final Album album;
  final List<Song> songs;

  @override
  List<Object> get props => [album];
}

class SingleAlbumError extends SingleAlbumState {}
