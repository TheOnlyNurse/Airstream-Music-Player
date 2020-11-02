import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Internal links
import '../repository/artist_repository.dart';
import '../repository/album_repository.dart';
import '../providers/moor_database.dart';
import '../repository/song_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    @required this.albumRepository,
    @required this.artistRepository,
    @required this.songRepository,
  }) : super(SearchInitial());

  final AlbumRepository albumRepository;
  final ArtistRepository artistRepository;
  final SongRepository songRepository;

  final queryList = <String>[];
  Timer _timer;

  @override
  Stream<SearchState> mapEventToState(SearchEvent event) async* {
    if (event is SearchQuery) {
      yield SearchLoading();

      if (_timer != null) {
        _timer.cancel();
        _timer = null;
      }
      queryList.add(event.query);
      _timer =
          Timer(Duration(milliseconds: 600), () => this.add(SearchFetch()));
    }

    if (event is SearchFetch) {
      if (queryList.isNotEmpty) {
        final query = queryList.last;
        queryList.clear();
        if (query.length > 1) {
          final songResults = await songRepository.search(query: query);
          final artistResults = await artistRepository.search(query);
          final albumResults = await albumRepository.search(query);
          final noResults = songResults.hasError &&
              artistResults.hasError &&
              albumResults.hasError;
          if (noResults) {
            yield SearchFailure(songResults.error);
          } else {
            yield SearchSuccess(
              songs: songResults.data ?? [],
              artists: artistResults.data ?? [],
              albums: albumResults.data ?? [],
            );
          }
        } else {
          yield SearchInitial();
        }
      }
    }
  }

  @override
  Future<void> close() {
    if (_timer != null) _timer.cancel();
    return super.close();
  }
}

abstract class SearchEvent {}

class SearchQuery extends SearchEvent {
  final String query;

  SearchQuery(this.query);
}

class SearchFetch extends SearchEvent {}

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  SearchSuccess({this.songs, this.albums, this.artists});
}

class SearchFailure extends SearchState {
  final String message;

  SearchFailure(this.message);
}
