import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:flutter/material.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final queryList = <String>[];
  Timer _timer;

  @override
  SearchState get initialState => SearchInitial();

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
          final songResults = await Repository().song.search(query: query);
          final artistResults = await Repository().artist.search(query: query);
          final albumResults = await Repository().album.search(request: query);
          final noResults = !songResults.hasData &&
              !artistResults.hasData &&
              !albumResults.hasData;
          if (noResults) {
            yield SearchFailure(songResults.message);
          } else {
            yield SearchSuccess(
              songs: songResults.songList ?? [],
              artists: artistResults.artists ?? [],
              albums: albumResults.albums ?? [],
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
  final Widget error;

  SearchFailure(this.error);
}
