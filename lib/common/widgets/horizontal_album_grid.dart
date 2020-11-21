import 'package:flutter/material.dart';

import '../../global_assets.dart';
import '../providers/moor_database.dart';
import 'album_card.dart';

class HorizontalAlbumGrid extends StatelessWidget {
  final List<Album> albums;
  final Function(Album) onTap;

  const HorizontalAlbumGrid({Key key, this.albums, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        physics: WidgetProperties.scrollPhysics,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.25 / 1,
          mainAxisSpacing: 10,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return AlbumCard(album: albums[index], onTap: onTap);
        },
      ),
    );
  }
}
