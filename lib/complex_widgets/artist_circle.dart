import 'package:airstream/providers/moor_database.dart';
import 'package:airstream/models/image_adapter.dart';
import 'package:flutter/material.dart';
import 'airstream_image.dart';

class ArtistCircle extends StatelessWidget {
  final Artist artist;
  final Function onTap;

  const ArtistCircle({Key key, this.artist, this.onTap}) : super(key: key);

  void _defaultOnTap(BuildContext context) {
    Navigator.pushNamed(
      context,
      'library/singleArtist',
      arguments: artist,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: _ImageWithInk(
              image: AirstreamImage(adapter: ImageAdapter(artist: artist)),
              onTap: () {
                onTap != null ? onTap(artist) : _defaultOnTap(context);
              }),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            artist.name,
            style: Theme.of(context).textTheme.headline6.copyWith(
                  fontWeight: FontWeight.normal,
                ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}

class _ImageWithInk extends StatelessWidget {
  final Widget image;
  final Function onTap;

  const _ImageWithInk({Key key, this.image, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          image,
          Material(
            color: Colors.transparent,
            elevation: 0.0,
            child: Ink(
              child: InkWell(
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
