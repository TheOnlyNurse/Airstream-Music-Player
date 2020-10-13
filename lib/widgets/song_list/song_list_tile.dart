import 'package:airstream/bloc/song_list_tile_bloc.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/events/song_list_tile_event.dart';
import 'package:airstream/states/song_list_tile_state.dart';
import 'package:airstream/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongListTile extends StatelessWidget {
  const SongListTile({
    @required this.song,
    @required this.animation,
    this.onLongPress,
    this.onTap,
    this.isSelected,
  })  : assert(song != null),
        assert(animation != null);

  final Song song;
  final Animation<double> animation;
  final Function onLongPress;
  final Function onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final _slideTween = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    );

    int _getPercent(SongListTileState state) {
      return state is SongListTileSuccess ? state.cachePercent : 0;
    }

    bool _getPlaying(SongListTileState state) {
      return state is SongListTileSuccess ? state.isPlaying : false;
    }

    return BlocProvider(
      create: (context) {
        return SongListTileBloc(tileSong: song)..add(SongListTileFetch());
      },
      child: BlocBuilder<SongListTileBloc, SongListTileState>(
        builder: (context, state) {
          return SlideTransition(
            position: animation.drive(_slideTween),
            child: SongTile(
              song: song,
              onTap: onTap,
              onLongPress: onLongPress,
              percentage: _getPercent(state),
              isPlaying: _getPlaying(state),
            ),
          );
        },
      ),
    );
  }
}