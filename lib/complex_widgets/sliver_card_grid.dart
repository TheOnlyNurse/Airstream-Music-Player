import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/models/static_assets.dart';
import '../complex_widgets/album_card.dart';
import 'package:flutter/material.dart';

class SliverAlbumGrid extends StatelessWidget {
  const SliverAlbumGrid({@required this.albumList});

  final List<Album> albumList;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 30.0),
      sliver: SliverGrid(
        gridDelegate: airstreamAlbumsDelegate,
        delegate: SliverChildBuilderDelegate(
          (context, int index) => AlbumCard(album: albumList[index]),
          childCount: albumList.length,
        ),
      ),
    );
  }
}
