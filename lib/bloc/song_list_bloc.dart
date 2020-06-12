import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/song_model.dart';
import 'package:bloc/bloc.dart';

abstract class SongListEvent {}

class FetchAlbumSongs extends SongListEvent {
  final Album album;

  FetchAlbumSongs(this.album);
}

class FetchPlaylistSongs extends SongListEvent {
  final Playlist playlist;

  FetchPlaylistSongs(this.playlist);
}

class JustDisplaySongs extends SongListEvent {
  final List<Song> songList;

  JustDisplaySongs(this.songList);
}

class FetchStarredSongs extends SongListEvent {}

abstract class SongListState {}

class SongListUninitialised extends SongListState {}

class SongListError extends SongListState {}

class SongListLoaded extends SongListState {
  final List<Song> songList;

  SongListLoaded(this.songList);
}

class SongListBloc extends Bloc<SongListEvent, SongListState> {
  @override
  SongListState get initialState => SongListUninitialised();

  @override
  Stream<SongListState> mapEventToState(SongListEvent event) async* {
    RepoResponse response;

    if (event is FetchAlbumSongs) {
      response = await Repository().getAlbumSongs(event.album);
    }
    if (event is FetchPlaylistSongs) {
      response = await Repository().getSongListByIds(event.playlist.songIds);
    }
    if (event is FetchStarredSongs) {
			response = await Repository().getLibrary(Library.songs);
    }

    if (response.status == DataStatus.ok)
      yield SongListLoaded(response.data);
    else
      yield SongListError();
  }
}
