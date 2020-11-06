/// External Packages
import 'package:flutter/material.dart';

/// Internal Links
import '../../providers/moor_database.dart';
import '../../providers/repository/repository.dart';
import '../song_tile.dart';

class PlayerQueue extends StatefulWidget {
  @override
  _PlayerQueueState createState() => _PlayerQueueState();
}

class _PlayerQueueState extends State<PlayerQueue> {
  List<Song> songs = Repository().audio.queue;

  List<Widget> _songTiles() {
    final tiles = <Widget>[];
    for (int i = 0; i < songs.length; i++) {
      tiles.add(
        SongTile(
          key: ValueKey(songs[i].id),
          leading: Icon(Icons.reorder),
          song: songs[i],
          onTap: () => Repository().audio.playIndex(i),
        ),
      );
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: _songTiles(),
      onReorder: (oldIndex, newIndex) async {
        Repository().audio.reorder(oldIndex, newIndex);
        setState(() {
          songs = Repository().audio.queue;
        });
      },
    );
  }
}
