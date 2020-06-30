import 'package:airstream/bloc/song_list_tile_bloc.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/states/song_list_tile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongListTile extends StatelessWidget {
  const SongListTile({
    @required this.song,
    this.onLongPress,
    this.onTap,
    this.trailing,
    this.animation,
  }) : assert(song != null);

  final Song song;
  final Function onLongPress;
  final Function onTap;
  final Widget trailing;
  final Animation<double> animation;

  static final _slideTween = Tween<Offset>(
    begin: const Offset(-1.0, 0.0),
    end: Offset.zero,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SongListTileBloc(tileSong: song),
      child: SlideTransition(
        position: animation.drive(_slideTween),
        child: Container(
          color: Colors.transparent,
          child: ListTile(
            onLongPress: onLongPress,
            contentPadding: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
            title: Text(song.title),
            subtitle: Text(
              song.artist,
              style: Theme.of(context).textTheme.caption,
            ),
            onTap: onTap,
            trailing: trailing ??
                BlocBuilder<SongListTileBloc, SongListTileState>(
                  builder: (context, state) {
                    if (state is SongListTileIsPaused) {
                      return Icon(Icons.pause_circle_outline);
                    }
                    if (state is SongListTileIsPlaying) {
                      return Icon(Icons.play_circle_outline);
                    }
                    if (state is SongListTileIsFinished) {
                      return Icon(Icons.check_circle_outline);
                    }

                    if (state is SongListTileIsDownloading) {
                      return SizedBox(
                        height: 30,
                        width: 30,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            value: state.percentage / 100,
                          ),
                        ),
                      );
										}

										return SizedBox();
                  },
                ),
          ),
        ),
      ),
    );
  }
}
