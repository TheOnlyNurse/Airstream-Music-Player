import 'package:flutter/material.dart';
import 'package:airstream/providers/moor_database.dart';

/// Internal Links
import '../static_assets.dart';
import '../complex_widgets/album_card.dart';

class SliverAlbumGrid extends StatelessWidget {
  const SliverAlbumGrid({Key key, this.albumList, this.onTap})
      : super(key: key);

  final List<Album> albumList;
  final void Function(Album) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30.0),
      sliver: SliverGrid(
        gridDelegate: airstreamAlbumsDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, int index) => AlbumCard(
            album: albumList[index],
            onTap: onTap,
          ),
          childCount: albumList.length,
        ),
      ),
    );
  }
}
