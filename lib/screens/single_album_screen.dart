import 'package:airstream/models/album_model.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:flutter/material.dart';

class SingleAlbumScreen extends StatelessWidget {
  final Album album;

  SingleAlbumScreen({this.album});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: SongList(
        album: album,
        initialSlivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).canvasColor,
            expandedHeight: 400,
            flexibleSpace: AirstreamImage(
              coverArt: album.coverArt,
              isHiDef: true,
            ),
            leading: RawMaterialButton(
              shape: CircleBorder(),
              child: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
