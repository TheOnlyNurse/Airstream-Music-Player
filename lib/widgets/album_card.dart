import 'package:airstream/models/album_model.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';

class AlbumCardWidget extends StatelessWidget {
  final Album album;
  final Function onTap;

  AlbumCardWidget({this.album, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: <Widget>[
            AirstreamImage(coverArt: album.coverArt),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  color: Theme.of(context).cardColor,
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        album.name,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      Text(
                        album.artistName,
                        overflow: TextOverflow.fade,
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 0.8, fontWeightDelta: -1),
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
