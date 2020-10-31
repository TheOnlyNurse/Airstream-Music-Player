import 'package:airstream/data_providers/moor_database.dart';
import '../complex_widgets/album_card.dart';
import 'package:flutter/material.dart';

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
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1.25 / 1,
          mainAxisSpacing: 10,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return AlbumCard(
            album: albums[index],
            onTap: (album) {
              if (onTap != null) {
                onTap(album);
              } else {
                Navigator.pushNamed(
                  context,
                  'library/singleAlbum',
                  arguments: album,
                );
              }
            },
          );
        },
      ),
    );
  }
}
