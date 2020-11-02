import 'package:airstream/repository/album_repository.dart';

/// External Packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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

  }
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
}

class SingleAlbumError extends SingleAlbumState {}
