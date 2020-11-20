import 'package:flutter/material.dart';

import '../providers/moor_database.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    Key key,
    @required this.song,
    this.onTap,
    this.onLongPress,
    this.height = 72,
    this.leading,
    this.trailing,
  })  : assert(song != null),
        super(key: key);

  final Song song;
  final void Function() onTap;
  final void Function() onLongPress;
  final double height;
  final Widget leading;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      trailing: trailing,
      leading: leading,
      title: Text(
        song.title,
        style: textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: textTheme.bodyText2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
