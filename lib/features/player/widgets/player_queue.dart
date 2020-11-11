import 'package:flutter/material.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/audio_repository.dart';
import '../../../common/widgets/song_tile.dart';

class PlayerQueue extends StatefulWidget {
  const PlayerQueue({Key key, @required this.audioRepository})
      : assert(audioRepository != null),
        super(key: key);
  final AudioRepository audioRepository;

  @override
  _PlayerQueueState createState() => _PlayerQueueState();
}

class _PlayerQueueState extends State<PlayerQueue> {
  List<Song> songs;

  @override
  void initState() {
    songs = widget.audioRepository.queue;
    super.initState();
  }

  List<Widget> _songTiles() {
    final tiles = <Widget>[];
    for (int i = 0; i < songs.length; i++) {
      tiles.add(
        SongTile(
          key: ValueKey(songs[i].id),
          leading: const Icon(Icons.reorder),
          song: songs[i],
          onTap: () => widget.audioRepository.play(i),
        ),
      );
    }
    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      onReorder: (oldIndex, newIndex) async {
        widget.audioRepository.reorder(oldIndex, newIndex);
        setState(() => songs = widget.audioRepository.queue);
      },
      children: _songTiles(),
    );
  }
}
