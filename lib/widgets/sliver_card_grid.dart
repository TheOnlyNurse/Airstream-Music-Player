import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/widgets/album_card.dart';
import 'package:flutter/material.dart';

class SliverAlbumGrid extends StatelessWidget {
  const SliverAlbumGrid({@required this.albumList});

  final List<Album> albumList;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1 / 1.25,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, int index) {
            return AlbumCard(
              album: albumList[index],
              onTap: (album) => Navigator.pushNamed(
                context,
                'library/singleAlbum',
                arguments: album,
              ),
            );
          },
          childCount: albumList.length,
        ),
      ),
    );
  }
}
