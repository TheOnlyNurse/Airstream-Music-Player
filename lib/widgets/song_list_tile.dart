import 'package:airstream/models/song_model.dart';
import 'package:flutter/material.dart';

class SongListTile extends StatelessWidget {
  final Song song;
  final onTap;

  SongListTile({@required this.song, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
      title: Text(song.title),
      subtitle: Text(
        song.artist,
        style: Theme.of(context).textTheme.caption,
      ),
      onTap: () => onTap(),
    );
  }
}
