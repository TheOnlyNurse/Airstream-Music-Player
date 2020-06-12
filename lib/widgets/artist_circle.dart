import 'package:airstream/models/artist_model.dart';
import 'package:flutter/material.dart';

import 'airstream_image.dart';

class ArtistCircle extends StatelessWidget {
  final Artist artist;
  final Function onTap;

  const ArtistCircle({Key key, this.artist, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8 / 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.hardEdge,
                child: AirstreamImage(coverArt: artist.art),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  artist.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
