import 'package:airstream/models/album_model.dart';
import 'package:equatable/equatable.dart';

abstract class LibraryAlbumsState extends Equatable {
  const LibraryAlbumsState();

  @override
  List<Object> get props => [];
}

class AlbumGridUninitialised extends LibraryAlbumsState {}

class AlbumGridError extends LibraryAlbumsState {}

class AlbumGridLoaded extends LibraryAlbumsState {
  final List<Album> albums;

  const AlbumGridLoaded({this.albums});

  @override
  List<Object> get props => [albums];

  @override
  String toString() => 'Loaded { # Artists: ${albums.length} }';
}
