import 'package:airstream/models/artist_model.dart';
import 'package:flutter/material.dart';

import 'airstream_image.dart';

class ArtistCircle extends StatelessWidget {
  final Artist artist;
  final Function onTap;

  const ArtistCircle({Key key, this.artist, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          Navigator.of(context).pushNamed(
            'library/singleArtist',
            arguments: artist,
          );
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.hardEdge,
                  child: AirstreamImage(
                    coverArt: artist.art,
                    height: constraints.maxHeight - 50,
                    width: constraints.maxWidth,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(
                    artist.name,
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
