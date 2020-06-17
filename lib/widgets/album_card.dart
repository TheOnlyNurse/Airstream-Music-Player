import 'package:airstream/models/album_model.dart';
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
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap(album);
          } else {
            Navigator.of(context).pushNamed(
              'library/singleAlbum',
              arguments: album,
            );
          }
        },
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: <Widget>[
              AirstreamImage(
                height: constraints.maxHeight - 50,
                width: constraints.maxWidth,
                coverArt: album.art,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        album.title,
                        overflow: TextOverflow.fade,
                        maxLines: 1,
                        softWrap: false,
                      ),
                      Text(
                        album.artist,
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.caption,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
