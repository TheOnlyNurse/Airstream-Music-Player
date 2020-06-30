import 'package:airstream/data_providers/moor_database.dart';
import 'package:equatable/equatable.dart';

abstract class StarredState extends Equatable {
  const StarredState();

  @override
  List<Object> get props => [];
}

class Uninitialised extends StarredState {}

class Error extends StarredState {}

class Loaded extends StarredState {
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
