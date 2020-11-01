import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/data_providers/repository/repository.dart';
import '../../complex_widgets/song_tile.dart';
import 'package:flutter/material.dart';

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
