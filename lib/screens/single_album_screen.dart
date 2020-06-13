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
        leading: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).canvasColor,
            expandedHeight: 400,
            flexibleSpace: AirstreamImage(
              coverArt: album.art,
              isHiDef: true,
            ),
            leading: RawMaterialButton(
              shape: CircleBorder(),
              child: Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
        onError: Stack(
          children: <Widget>[
            Center(child: Text('Unable to load album')),
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
