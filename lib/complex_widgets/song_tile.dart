import 'package:airstream/providers/moor_database.dart';
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final Function onTap;
  final Function onLongPress;
  final int percentage;
  final bool isPlaying;
  final double height;
  final Widget leading;

  const SongTile({
    Key key,
    @required this.song,
    this.onTap,
    this.onLongPress,
    this.percentage = 0,
    this.isPlaying = false,
    this.height = 72,
    this.leading,
  })  : assert(song != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(child: _SongListTile(song: song)),
              _TileStatus(percentage: percentage, isPlaying: isPlaying),
            ],
          ),
          Material(
            color: Colors.transparent,
            elevation: 0.0,
            child: Ink(
              child: InkWell(onTap: onTap),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongListTile extends StatelessWidget {
  final Song song;
  final Function onTap;
  final Function onLongPress;

  const _SongListTile({
    Key key,
    @required this.song,
    this.onTap,
    this.onLongPress,
  })  : assert(song != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      title: Text(
        song.title,
        style: text.subtitle1.copyWith(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: text.bodyText2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class _TileStatus extends StatelessWidget {
  final bool isPlaying;
  final int percentage;
  final double height;

  const _TileStatus({
    Key key,
    this.percentage = 0,
    this.isPlaying = false,
    this.height = 72,
  }) : super(key: key);

  double _height() {
    if (percentage > 0 && percentage < 100) {
      return height * (percentage / 100);
    } else {
      return height;
    }
  }

  Color _colour(BuildContext context) {
    if (isPlaying) {
      return Theme.of(context).accentColor;
    }
    if (percentage == 0) {
      return Theme.of(context).errorColor;
    } else {
      return Theme.of(context).disabledColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: 5,
      child: Column(
        children: [
          Spacer(),
          Container(
            height: _height(),
            color: _colour(context),
          ),
        ],
      ),
    );
  }
}
