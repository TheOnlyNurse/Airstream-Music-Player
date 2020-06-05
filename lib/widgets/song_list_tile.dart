import 'package:airstream/models/song_model.dart';
import 'package:flutter/material.dart';

class SongListTile extends StatelessWidget {
  final Song song;
  final tapCallback;

  SongListTile({this.song, this.tapCallback});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
      title: Text(song.name),
      subtitle: Text(
        song.artistName,
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 0.8),
      ),
      onTap: () => tapCallback(),
    );
  }
}
