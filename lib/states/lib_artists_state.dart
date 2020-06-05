import 'package:airstream/models/artist_model.dart';
import 'package:equatable/equatable.dart';

abstract class LibraryAlbumsState extends Equatable {
  const LibraryAlbumsState();

  @override
  List<Object> get props => [];
}

class Uninitialised extends LibraryAlbumsState {}

class Error extends LibraryAlbumsState {}

class Loaded extends LibraryAlbumsState {
  final List<Artist> artists;

  const Loaded({this.artists});

//  For ease of instance copying
  Loaded copyWith({List<Artist> posts, bool hasReachedMax}) {
    return Loaded(
      artists: artists ?? this.artists,
    );
  }

  @override
  List<Object> get props => [artists];

  @override
  String toString() => 'ArtistsLoaded { # Artists: ${artists.length} }';
}
