part of '../sliver_song_list.dart';

class _SongListTile extends StatelessWidget {
  const _SongListTile({
    @required this.song,
    @required this.bloc,
    this.onLongPress,
    this.onTap,
    this.isSelected,
  }) : assert(song != null);

  final Song song;
  final SongListTileBloc bloc;
  final void Function() onLongPress;
  final void Function() onTap;
  final bool isSelected;

  /// Shows download percent or play arrow if applicable to this tile.
  List<double> _stops(double cachePercent) {
    if (cachePercent == 0.0) {
      return [1,1];
    } else if (cachePercent < 1.0) {
      return [math.max(0.8 - cachePercent, 0.0), 1.0 - cachePercent];
    } else {
      return [0,0];
    }
  }

  List<Color> _colours(bool isPlaying, BuildContext context) {
    final playing = Theme.of(context).accentColor;
    const cached = Colors.transparent;
    final notCached = Theme.of(context).errorColor;
    return isPlaying ? [playing, playing] : [notCached, cached];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SongListTileBloc, SongListTileState>(
      cubit: bloc,
      builder: (context, state) {
        return SongTile(
          song: song,
          onTap: onTap,
          onLongPress: onLongPress,
          trailing: Container(
            width: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(0,1),
                end: const Alignment(0,-1),
                stops: _stops(state.cachePercent),
                colors: _colours(state.isPlaying, context),
              )
            ),
          ),
        );
      },
    );
  }
}
