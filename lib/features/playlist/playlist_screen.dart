import 'package:flutter/material.dart';

/// Internal
import '../../common/models/playlist_model.dart';
import '../../common/models/song_list_delegate.dart';
import '../../common/song_list/song_list.dart';

class SinglePlaylistScreen extends StatelessWidget {
  final Playlist playlist;

  const SinglePlaylistScreen({Key key, this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SongList(
        delegate: PlaylistSongList(playlist: playlist),
        sliverAppBar: SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          leading: RawMaterialButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close),
          ),
        ),
        sliverTitle: SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              playlist.name,
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
      ),
    );
  }
}
