import 'package:flutter/material.dart';

/// Internal
import '../providers/moor_database.dart';
import '../providers/repository/repository.dart';
import '../widgets/song_tile.dart';

class SliverSongList extends StatelessWidget {
  final List<Song> songs;

  const SliverSongList({Key key, @required this.songs})
      : assert(songs != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return SongTile(
              song: songs[index],
              onLongPress: null,
              onTap: () {
                Repository().audio.start(playlist: songs, index: index);
              },
            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}
