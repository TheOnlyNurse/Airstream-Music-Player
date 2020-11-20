import 'package:flutter/material.dart';

import '../models/image_adapter.dart';
import '../providers/moor_database.dart';
import 'airstream_image.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final void Function(Album) onTap;

  const AlbumCard({@required this.album, this.onTap});

  void _defaultOnTap(BuildContext context) {
    Navigator.pushNamed(
      context,
      'library/singleAlbum',
      arguments: album,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.hardEdge,
      child: DecoratedBox(
        decoration: BoxDecoration(color: Theme.of(context).cardColor),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child:
                      AirstreamImage(adapter: AlbumImageAdapter(album: album)),
                ),
                const SizedBox(height: 8),
                _Titles(title: album.title, isSubtitle: false),
                _Titles(title: album.artist, isSubtitle: true),
                const SizedBox(height: 8),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: Ink(
                child: InkWell(onTap: () {
                  onTap == null ? _defaultOnTap(context) : onTap(album);
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titles extends StatelessWidget {
  final String title;
  final bool isSubtitle;

  const _Titles({Key key, this.title, this.isSubtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
        style: isSubtitle ? _theme.caption : _theme.bodyText1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
