import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';

/// Internal links
import '../providers/repository/repository.dart';
import '../events/song_list_event.dart';
import '../models/playlist_model.dart';
import '../models/repository_response.dart';
import '../models/song_list_delegate.dart';
import '../states/song_list_state.dart';
import '../repository/song_repository.dart';
import '../providers/moor_database.dart';

// Barrelling
export '../events/song_list_event.dart';
export '../states/song_list_state.dart';

class SongListBloc extends Bloc<SongListEvent, SongListState> {
  SongListBloc({@required this.songRepository}) : super(SongListInitial());

  final SongRepository songRepository;
  Playlist playlist;

  SongListState _successOrFailure(ListResponse<Song> response) {
    if (response.hasData) {
      return SongListSuccess(songList: response.data);
    } else {
      return SongListFailure(Text(response.error));
    }
  }

  @override
  Stream<SongListState> mapEventToState(SongListEvent event) async* {
    final currentState = state;

    if (event is SongListFetch) {
      final delegate = event.delegate;

      if (delegate is PlaylistSongList) {
        playlist = delegate.playlist;
        final response = await songRepository.fromPlaylist(delegate.playlist);
        yield _successOrFailure(response);
      }

      if (delegate is AlbumSongList) {
        final response = await songRepository.fromAlbum(delegate.album);
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
