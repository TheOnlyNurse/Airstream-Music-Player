import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final Function(Album) onTap;

  AlbumCard({@required this.album, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          child: Stack(children: <Widget>[
            Column(
              children: <Widget>[
                AirstreamImage(
                  height: constraints.maxHeight - 50,
                  width: constraints.maxWidth,
                  coverArt: album.art,
                  isThumbnail: true,
                ),
                Expanded(
                  child: _Titles(title: album.title, artist: album.artist),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              elevation: 0.0,
              child: Ink(
                child: InkWell(onTap: () => onTap(album) ?? null),
              ),
            ),
          ]),
        );
      }),
    );
  }
}

class _Titles extends StatelessWidget {
  final String title;
  final String artist;

  const _Titles({Key key, this.title, this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            overflow: TextOverflow.fade,
            maxLines: 1,
            softWrap: false,
          ),
          Text(
            artist,
            overflow: TextOverflow.fade,
            style: Theme.of(context).textTheme.caption,
            maxLines: 1,
            softWrap: false,
          ),
        ],
      ),
    );
  }
}
