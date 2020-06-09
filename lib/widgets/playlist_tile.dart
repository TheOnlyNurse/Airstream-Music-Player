import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/widgets/airstream_collage.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;

  const PlaylistTile({Key key, this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final songs = playlist.songList;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        'library/singlePlaylist',
        arguments: playlist,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: Colors.transparent,
        // The container only expands when it has at least this property
        child: Row(
          children: <Widget>[
            Container(
              height: 100,
              width: 100,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              child: songs.length > 4
                  ? AirstreamCollage(artistIdList: songs.sublist(0, 4))
                  : songs.isNotEmpty
                      ? AirstreamImage(songId: songs[0])
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.asset('lib/graphics/album.png'),
                        ),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  playlist.name,
                  style: Theme.of(context).textTheme.headline5,
                ),
                if (playlist.comment != null)
                  Text(
                    playlist.comment,
                    style: Theme.of(context).textTheme.caption,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
