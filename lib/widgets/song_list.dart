import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/song_model.dart';
import 'package:flutter/material.dart';

class SongList extends StatelessWidget {
  final List<Song> songList;

  SongList({@required this.songList});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 30.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, int index) {
            if (index.isEven) {
              final i = index ~/ 2;
              return _SongListTile(
                song: songList[i],
                tapCallback: () => Repository().createQueueAndPlay(
                  playlist: songList,
                  index: i,
                ),
              );
            }
            return Divider(
              indent: 30.0,
              endIndent: 30.0,
            );
          },
          childCount: songList.length * 2 - 1,
        ),
      ),
    );
  }
}

class _SongListTile extends StatelessWidget {
  final Song song;
  final tapCallback;

  _SongListTile({this.song, this.tapCallback});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0),
      title: Text(song.name),
      subtitle: Text(
				song.artistName,
				style: Theme
						.of(context)
						.textTheme
						.caption,
			),
			onTap: () => tapCallback(),
		);
	}
}
