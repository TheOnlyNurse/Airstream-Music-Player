part of 'album_cubit.dart';

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

class SingleAlbumError extends SingleAlbumState {
  const SingleAlbumError(this.message);

  final String message;
}