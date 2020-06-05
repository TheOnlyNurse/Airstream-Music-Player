import 'package:airstream/models/song_model.dart';
import 'package:equatable/equatable.dart';

abstract class LibraryStarredState extends Equatable {
  const LibraryStarredState();

  @override
  List<Object> get props => [];
}

class Uninitialised extends LibraryStarredState {}

class Error extends LibraryStarredState {}

class Loaded extends LibraryStarredState {
  final List<Song> songs;

  const Loaded({this.songs});

//  For ease of instance copying
  Loaded copyWith({List<Song> posts, bool hasReachedMax}) {
    return Loaded(
      songs: songs ?? this.songs,
    );
  }

  @override
  List<Object> get props => [songs];

  @override
  String toString() => 'Starred { # Artists: ${songs.length} }';
}
