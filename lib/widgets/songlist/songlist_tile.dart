import 'package:airstream/models/song_model.dart';
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  const SongTile({
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
    return SlideTransition(
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
          trailing: trailing,
        ),
      ),
    );
  }
}
