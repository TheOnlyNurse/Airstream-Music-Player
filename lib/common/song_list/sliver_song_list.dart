import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/moor_database.dart';
import '../repository/audio_repository.dart';
import '../selection_bar/bloc/selection_bar_cubit.dart';
import '../widgets/song_tile.dart';
import 'bloc/song_list_tile_cubit.dart';

part 'widgets/song_list_tile.dart';

class SliverSongList extends StatelessWidget {
  final List<Song> songs;
  final AudioRepository audioRepository;

  const SliverSongList({
    Key key,
    @required this.songs,
    @required this.audioRepository,
  })  : assert(songs != null),
        assert(audioRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectionBarCubit = context.read<SelectionBarCubit>();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _SongListTile(
              song: songs[index],
              cubit: SongListTileCubit(
                song: songs[index],
                audio: audioRepository,
                selectionBarCubit: selectionBarCubit,
              )..checkCache(),
              onTap: () => audioRepository.start(songs: songs, index: index),
            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}
