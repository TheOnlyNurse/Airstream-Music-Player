import 'dart:math' as math;

import 'package:airstream/common/song_list_bar/bloc/selection_bar_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/moor_database.dart';
import '../repository/audio_repository.dart';
import '../widgets/song_tile.dart';
import 'bloc/song_list_tile_bloc.dart';

part 'widgets/song_list_tile.dart';

class SliverSongList extends StatelessWidget {
  final List<Song> songs;
  final AudioRepository audioRepository;
  final SelectionBarCubit selectionBarCubit;

  const SliverSongList({
    Key key,
    @required this.songs,
    @required this.audioRepository,
    this.selectionBarCubit,
  })  : assert(songs != null),
        assert(audioRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _SongListTile(
            song: songs[index],
            bloc: SongListTileBloc(
              song: songs[index],
              audio: audioRepository,
              selectionBarCubit: selectionBarCubit,
            )..checkCache(),
            onTap: () => audioRepository.start(songs: songs, index: index),
          );
        },
        childCount: songs.length,
      ),
    );
  }
}
