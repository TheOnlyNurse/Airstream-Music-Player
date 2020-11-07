import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Internal links
import '../../../common/repository/artist_repository.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/providers/moor_database.dart';
import '../../../common/repository/song_repository.dart';

part 'search_event.dart';

part 'search_state.dart';

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
      _timer = Timer(Duration(milliseconds: 600), () {
        this.add(SearchFetch());
      });
    }

    if (event is SearchFetch && queryList.isNotEmpty) {
      final query = queryList.last;
      queryList.clear();
      if (query.length > 1) {
        final songResults = await songRepository.search(query);
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

  @override
  Future<void> close() {
    if (_timer != null) _timer.cancel();
    return super.close();
  }
}