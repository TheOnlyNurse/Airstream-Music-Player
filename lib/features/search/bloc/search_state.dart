import 'package:equatable/equatable.dart';

import '../../../common/providers/moor_database.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  const SearchSuccess({this.songs, this.albums, this.artists});

  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  @override
  List<Object> get props => [songs, albums, artists];
}

class SearchFailure extends SearchState {}
