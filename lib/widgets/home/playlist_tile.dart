import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/widgets/airstream_collage.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';

class PlaylistTile extends StatelessWidget {
  final Playlist playlist;

  const PlaylistTile({Key key, this.playlist}) : super(key: key);

  Widget _getImage(List<int> songIds) {
    if (songIds.length > 3) {
      return AirstreamCollage(songIds: songIds.sublist(0, 4));
    } else if (songIds.isNotEmpty) {
      return AirstreamImage(songId: songIds.first);
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Image.asset('lib/graphics/album.png'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: SizedBox(
        height: 100,
        child: Stack(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  child: _getImage(playlist.songIds),
                ),
                SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 12),
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
            Material(
              elevation: 0,
              color: Colors.transparent,
              child: Ink(
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () => Navigator.of(context).pushNamed(
                    'library/singlePlaylist',
                    arguments: playlist,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
