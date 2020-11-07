import 'dart:async';


import 'package:flutter/widgets.dart';
import 'package:bloc/bloc.dart';

import '../../models/playlist_model.dart';
import '../../models/repository_response.dart';
import '../../models/song_list_delegate.dart';
import '../../repository/song_repository.dart';
import '../../providers/moor_database.dart';
import '../../repository/playlist_repository.dart';

part 'song_list_event.dart';

part 'song_list_state.dart';

class SongListBloc extends Bloc<SongListEvent, SongListState> {
  SongListBloc({
    @required this.songRepository,
    @required this.playlistRepository,
  })  : assert(songRepository != null),
        assert(playlistRepository != null),
        super(SongListInitial());

  final SongRepository songRepository;
  final PlaylistRepository playlistRepository;
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
        final response = await songRepository.byPlaylist(delegate.playlist);
        yield _successOrFailure(response);
      }

      if (delegate is AlbumSongList) {
        final response = await songRepository.byAlbum(delegate.album);
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

        playlistRepository.addSongs(event.playlist, addedSongs);
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
          playlistRepository.removeSongs(playlist, currentState.selected);
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
