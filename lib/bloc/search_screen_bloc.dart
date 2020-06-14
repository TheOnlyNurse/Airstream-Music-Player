import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/models/song_model.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

class SearchBloc extends Bloc<String, SearchState> {
  @override
  SearchState get initialState => SearchInitial();

  @override
  Stream<SearchState> mapEventToState(String query) async* {
    if (query.length > 1) {
      yield SearchLoading();
      final songResults = await Repository().song.query(query: query);
      final artistResults = await Repository().artist.query(query: query);
      final albumResults = await Repository().album.query(query: query);
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
