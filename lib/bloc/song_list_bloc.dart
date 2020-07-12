import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/events/song_list_event.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/models/response/song_response.dart';
import 'package:airstream/models/song_list_delegate.dart';
import 'package:airstream/states/song_list_state.dart';

// Barrelling
export 'package:airstream/events/song_list_event.dart';
export 'package:airstream/states/song_list_state.dart';

class SongListBloc extends Bloc<SongListEvent, SongListState> {
  final _repository = Repository();
  Playlist playlist;

  SongListState _successOrFailure(SongResponse response) {
    if (response.hasData) {
      return SongListSuccess(songList: response.songs);
    } else {
      return SongListFailure(response.error);
    }
  }

  @override
  SongListState get initialState => SongListInitial();

  @override
  Stream<SongListState> mapEventToState(SongListEvent event) async* {
    final currentState = state;

    if (event is SongListFetch) {
      final delegate = event.delegate;

      if (delegate is PlaylistSongList) {
        playlist = delegate.playlist;
        final response = await _repository.song.fromPlaylist(delegate.playlist);
        yield _successOrFailure(response);
      }

      if (delegate is AlbumSongList) {
        final response = await _repository.song.fromAlbum(delegate.album);
        yield _successOrFailure(response);
      }

      if (delegate is SimpleSongList) {
				yield SongListSuccess(songList: delegate.initialSongs);
      }
    }

    if (currentState is SongListSuccess) {
      if (event is SongListSelection) {
        if (currentState.selected.contains(event.index)) {
          currentState.selected.remove(event.index);
        } else {
          currentState.selected.add(event.index);
        }

        yield currentState.copyWith(selected: currentState.selected);
      }

      if (event is SongListClearSelection) {
        yield currentState.copyWith(selected: []);
      }

      if (event is SongListPlaylistSelection) {
        final addedSongs = <Song>[];

        for (int index in currentState.selected) {
          addedSongs.add(currentState.songList[index]);
        }

        Repository().playlist.addSongs(event.playlist, addedSongs);
        this.add(SongListClearSelection());
      }

      if (event is SongListRemoveSelection) {
        final songList = currentState.songList;
        final removeMap = <int, Song>{};
        currentState.selected.sort((a, b) => b.compareTo(a));

        for (int index in currentState.selected) {
          removeMap[index] = currentState.songList[index];
          songList.remove(removeMap[index]);
        }

        if (playlist != null) {
          Repository().playlist.removeSongs(playlist, currentState.selected);
        }

        yield currentState.copyWith(
          songList: songList,
          selected: [],
          removeMap: removeMap,
        );
      }
    }
  }
}
