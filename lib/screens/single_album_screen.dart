import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/models/image_adapter.dart';
import 'package:airstream/models/song_list_delegate.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/song_list/song_list.dart';
import 'package:flutter/material.dart';

class SingleAlbumScreen extends StatelessWidget {
  final Album album;

  SingleAlbumScreen({this.album});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: backgroundColor,
      child: SongList(
        delegate: AlbumSongList(album: album),
        leading: <Widget>[
          SliverAppBar(
            backgroundColor: backgroundColor,
            automaticallyImplyLeading: false,
            titleSpacing: 4,
            expandedHeight: 400,
            flexibleSpace: AirstreamImage(
              adapter: ImageAdapter(album: album, isHiDef: true),
            ),
            title: RawMaterialButton(
              constraints: BoxConstraints.tightFor(width: 60, height: 60),
              onPressed: () => Navigator.pop(context),
              shape: CircleBorder(),
              child: Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
