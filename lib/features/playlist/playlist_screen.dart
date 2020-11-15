import 'package:airstream/common/song_list/sliver_song_list.dart';
import 'package:flutter/material.dart';

/// Internal
import '../../common/models/playlist_model.dart';

class SinglePlaylistScreen extends StatelessWidget {
  final Playlist playlist;

  const SinglePlaylistScreen({Key key, this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: RawMaterialButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              playlist.name,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
        const SliverSongList(songs: []),
      ],
    );
  }
}
