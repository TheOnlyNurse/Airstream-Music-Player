import 'package:airstream/data_providers/moor_database.dart';
import 'package:flutter/material.dart';
import 'airstream_image.dart';

class ArtistCircle extends StatelessWidget {
  final Artist artist;
  final Function onTap;

  const ArtistCircle({Key key, this.artist, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _Image(
                art: artist.art,
                constraints: constraints,
                stackChild: Material(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Ink(
                    child: InkWell(
                      onTap: () => onTap != null ? onTap(artist) : null,
                    ),
                  ),
                ),
              ),
              _ArtistName(name: artist.name),
            ],
          ),
        );
      },
    );
  }
}

class _Image extends StatelessWidget {
  final String art;
  final BoxConstraints constraints;
  final Widget stackChild;

  const _Image({Key key, this.art, this.constraints, this.stackChild})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = constraints.maxHeight - 50;
    final width = constraints.maxWidth;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: <Widget>[
            AirstreamImage(
              coverArt: art,
              height: height,
              width: width,
              isThumbnail: true,
            ),
            if (stackChild != null) stackChild,
          ],
        ),
      ),
    );
  }
}

class _ArtistName extends StatelessWidget {
  final String name;

  const _ArtistName({Key key, @required this.name})
      : assert(name != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        name,
        style: Theme.of(context).textTheme.subtitle1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      ),
    );
  }
}
