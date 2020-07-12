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

    Widget _displayState(SongListTileState state) {
      if (state is SongListTileSuccess) {
        return _TileStatus(
          percentage: state.cachePercent,
          isPlaying: state.isPlaying,
        );
      }
      return _TileStatus();
    }

    return BlocProvider(
      create: (context) {
        return SongListTileBloc(tileSong: song)..add(SongListTileFetch());
      },
      child: BlocBuilder<SongListTileBloc, SongListTileState>(
        builder: (context, state) {
          return SlideTransition(
            position: animation.drive(_slideTween),
            child: Stack(
              children: <Widget>[
                SongTile(song: song),
                Material(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Ink(
                    child: InkWell(
                      onTap: onTap,
                      onLongPress: onLongPress,
                      child: _displayState(state),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TileStatus extends StatelessWidget {
  final bool isPlaying;
  final int percentage;

  const _TileStatus({
    Key key,
    this.percentage = 0,
    this.isPlaying = false,
  }) : super(key: key);

  double _containerWidth(double maxWidth) {
    if (percentage > 0 && percentage < 100) {
      return (maxWidth - 20) * ((100 - percentage) / 100);
    } else if (percentage == 100) {
      return 5;
    } else {
      return maxWidth - 20;
    }
  }

  BoxBorder _boxBorder(BuildContext context) {
    if (percentage > 0 && percentage < 100) {
      return Border(
        left: BorderSide(color: Theme
            .of(context)
            .primaryColor, width: 2),
      );
    } else {
      return null;
    }
  }

  Color _containerColor(BuildContext context) {
    if (isPlaying) {
      return Theme
          .of(context)
          .accentColor;
    } else if (percentage == 100) {
      return Colors.transparent;
    } else {
      return Colors.black.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            width: _containerWidth(MediaQuery
                .of(context)
                .size
                .width),
            decoration: BoxDecoration(
              color: _containerColor(context),
              border: _boxBorder(context),
            ),
          )
        ],
      ),
    );
  }
}
