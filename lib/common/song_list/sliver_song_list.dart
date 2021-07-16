import 'package:airstream/global_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/moor_database.dart';
import '../repository/audio_repository.dart';
import '../selection_bar/bloc/selection_bar_cubit.dart';
import 'bloc/song_list_tile_cubit.dart';
import 'widgets/song_list_tile.dart';

class SliverSongList extends StatelessWidget {
  final List<Song> songs;
  final AudioRepository audioRepository;

  SliverSongList({
    Key key,
    @required this.songs,
    AudioRepository audioRepository,
  })  : assert(songs != null),
        audioRepository = audioRepository ?? getIt.get<AudioRepository>(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return SongListTile(
              song: songs[index],
              cubit: SongListTileCubit(
                song: songs[index],
                selectionBarCubit: context.read<SelectionBarCubit>(),
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
