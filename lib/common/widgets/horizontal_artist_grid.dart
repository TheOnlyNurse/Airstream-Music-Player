import 'package:flutter/material.dart';

import '../providers/moor_database.dart';
import '../static_assets.dart';
import 'artist_circle.dart';

class HorizontalArtistGrid extends StatelessWidget {
  final List<Artist> artists;
  final Function(Artist) onTap;

  const HorizontalArtistGrid({
    Key key,
    @required this.artists,
    this.onTap,
  })  : assert(artists != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 1 / 0.8,
          mainAxisSpacing: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: WidgetProperties.scrollPhysics,
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          return ArtistCircle(artist: artists[index], onTap: onTap);
        },
      ),
    );
  }
}
