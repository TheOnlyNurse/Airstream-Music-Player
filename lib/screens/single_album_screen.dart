import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/songlist/song_list.dart';
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
        type: SongListType.album,
        typeValue: album,
        leading: <Widget>[
          SliverAppBar(
            backgroundColor: backgroundColor,
            automaticallyImplyLeading: false,
            titleSpacing: 12,
            expandedHeight: 400,
            flexibleSpace: AirstreamImage(coverArt: album.art, isHiDef: true),
            title: SizedBox(
              width: 50,
              height: 50,
              child: OutlineButton(
                onPressed: () => Navigator.pop(context),
                padding: const EdgeInsets.only(right: 0),
                child: Icon(Icons.close, color: Theme.of(context).accentColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
