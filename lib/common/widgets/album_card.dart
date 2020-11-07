import 'package:flutter/material.dart';

/// Internal Links
import 'airstream_image.dart';
import '../providers/moor_database.dart';
import '../models/image_adapter.dart';

class AlbumCard extends StatelessWidget {
  final Album album;
  final void Function(Album) onTap;

  AlbumCard({@required this.album, this.onTap});

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
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: AirstreamImage(adapter: ImageAdapter(album: album)),
                ),
                SizedBox(height: 8),
                _Titles(title: album.title, isSubtitle: false),
                _Titles(title: album.artist, isSubtitle: true),
                SizedBox(height: 8),
              ],
            ),
            Material(
              color: Colors.transparent,
              elevation: 0.0,
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
