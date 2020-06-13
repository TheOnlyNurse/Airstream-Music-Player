import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:flutter/material.dart';

class SinglePlaylistScreen extends StatelessWidget {
  final Playlist playlist;

  const SinglePlaylistScreen({Key key, this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SongList(
        playlist: playlist,
        leading: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            leading: RawMaterialButton(
              shape: CircleBorder(),
              child: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
        onError: Stack(
          children: <Widget>[
            Center(child: Text('Unable to load playlist')),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: RawMaterialButton(
                  shape: CircleBorder(),
                  constraints: BoxConstraints.tightFor(
                    width: 60,
                    height: 60,
                  ),
                  child: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
