import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:bloc/bloc.dart';

abstract class SearchScreenState {}

class SearchResultsLoaded extends SearchScreenState {
  final List<Song> songList;
  final List<Album> albumList;
  final List<Artist> artistList;

  SearchResultsLoaded({this.songList, this.albumList, this.artistList});
}

class NoSearchResults extends SearchScreenState {}

class LoadingSearchResults extends SearchScreenState {}

class NoSearchRequested extends SearchScreenState {}

class SearchScreenBloc extends Bloc<String, SearchScreenState> {
  @override
  SearchScreenState get initialState => NoSearchRequested();

  @override
  Stream<SearchScreenState> mapEventToState(String event) async* {
    if (event.length > 1) {
      yield LoadingSearchResults();
      final songResults = await Repository().search(event, Library.songs);
      final artistResults = await Repository().search(event, Library.artists);
      final albumResults = await Repository().search(event, Library.albums);
      if (songResults.status == DataStatus.error &&
          artistResults.status == DataStatus.error &&
          albumResults.status == DataStatus.error) {
        yield NoSearchResults();
      } else {
        yield SearchResultsLoaded(
          songList: songResults.data ?? [],
          artistList: artistResults.data ?? [],
          albumList: albumResults.data ?? [],
        );
      }
    } else {
      yield NoSearchRequested();
    }
  }
}
