import 'package:airstream/models/artist_model.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';

class ArtistCardWidget extends StatelessWidget {
  final Artist artist;
  final Function onTap;

  ArtistCardWidget({this.artist, this.onTap});

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
              AirstreamImage(coverArt: artist.coverArt),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    color: Theme.of(context).cardColor,
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      artist.name,
                      overflow: TextOverflow.fade,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
