import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/song_model.dart';
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
      _timer = Timer(Duration(milliseconds: 600), () => this.add(SearchFetch()));
    }

    if (event is SearchFetch) {
      if (queryList.isNotEmpty) {
        final query = queryList.last;
        queryList.clear();
        if (query.length > 1) {
          final songResults = await Repository().song.query(query: query);
          final artistResults = await Repository().artist.query(query: query);
          final albumResults = await Repository().album.search(query: query);
          if ((songResults.status == DataStatus.error) &&
              (artistResults.status == DataStatus.error) &&
              (albumResults.status == DataStatus.error)) {
            yield SearchFailure(songResults.message);
          } else {
            yield SearchSuccess(
              songList: songResults.data ?? [],
              artistList: artistResults.data ?? [],
              albumList: albumResults.data ?? [],
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
  final List<Song> songList;
  final List<Album> albumList;
  final List<Artist> artistList;

  SearchSuccess({this.songList, this.albumList, this.artistList});
}

class SearchFailure extends SearchState {
  final Widget error;

  SearchFailure(this.error);
}
