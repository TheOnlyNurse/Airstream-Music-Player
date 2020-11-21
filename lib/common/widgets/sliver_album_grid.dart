import 'package:flutter/material.dart';

import '../../global_assets.dart';
import '../providers/moor_database.dart';
import '../widgets/album_card.dart';

class SliverAlbumGrid extends StatelessWidget {
  const SliverAlbumGrid({Key key, @required this.albums, this.onTap})
      : assert(albums != null),
        super(key: key);

  final List<Album> albums;
  final void Function(Album) onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30.0),
      sliver: SliverGrid(
        gridDelegate: WidgetProperties.albumsDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, int index) => AlbumCard(
            album: albums[index],
            onTap: onTap,
          ),
          childCount: albums.length,
        ),
      ),
    );
  }
}
