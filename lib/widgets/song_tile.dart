import 'package:airstream/data_providers/moor_database.dart';
import 'package:flutter/material.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final Widget leading;
  final Function onTap;
  final Function onLongPress;

  const SongTile({
    Key key,
    @required this.song,
    this.onTap,
    this.onLongPress,
    this.leading,
  })  : assert(song != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: leading,
      title: Text(
        song.title,
        style: Theme.of(context).textTheme.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: Theme.of(context).textTheme.bodyText2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
