import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/songlist/song_list.dart';
import 'package:flutter/material.dart';

class SingleAlbumScreen extends StatelessWidget {
  final Album album;

  SingleAlbumScreen({this.album});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    Widget _closeText({Color color, Paint foreground}) {
      return Text(
        'Back',
        style: Theme.of(context).textTheme.headline6.copyWith(
              foreground: foreground,
              color: color,
            ),
      );
    }

    return Container(
      color: backgroundColor,
      child: SongList(
        type: SongListType.album,
        typeValue: album,
        leading: <Widget>[
          SliverAppBar(
            backgroundColor: backgroundColor,
            automaticallyImplyLeading: false,
            titleSpacing: 4,
            expandedHeight: 400,
            flexibleSpace: AirstreamImage(coverArt: album.art, isHiDef: true),
            title: SizedBox(
              width: 80,
              height: 50,
              child: RawMaterialButton(
                onPressed: () => Navigator.pop(context),
                child: Stack(
                  children: <Widget>[
                    _closeText(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 3
                        ..color = Theme.of(context).primaryColor,
                    ),
                    _closeText(color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
