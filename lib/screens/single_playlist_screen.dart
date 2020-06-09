import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:flutter/material.dart';

class SinglePlaylistScreen extends StatelessWidget {
  final Playlist playlist;

  const SinglePlaylistScreen({Key key, this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SongList(playlist: playlist),
    );
  }
}
