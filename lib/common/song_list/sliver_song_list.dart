import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Internal
import '../providers/moor_database.dart';
import '../repository/audio_repository.dart';
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
              onTap: () {
                final repository = GetIt.I.get<AudioRepository>();
                repository.start(songs: songs, index: index);
              },
            );
          },
          childCount: songs.length,
        ),
      ),
    );
  }
}
