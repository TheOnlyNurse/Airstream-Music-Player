import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/screens/album_list_screen.dart';
import 'package:airstream/screens/alphabet_screen.dart';
import 'package:airstream/screens/artists_screen.dart';
import 'package:airstream/screens/decade_screen.dart';
import 'package:airstream/screens/genre_screen.dart';
import 'package:airstream/screens/random_screen.dart';
import 'package:flutter/material.dart';

class Collections extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final collections = <_CollectionDetails>[
      _CollectionDetails('Random', 'woodtype.jpg', page: RandomScreen()),
      _CollectionDetails(
        'Recently Added',
        'vegetables.jpg',
        page: AlbumListScreen(
          future: () => Repository().album.newlyAdded(),
          title: 'Recently Added',
        ),
      ),
      _CollectionDetails(
        'Most Played',
        'girl.jpg',
        page: AlbumListScreen(
          future: () => Repository().album.frequent(),
          title: 'Most Played',
        ),
      ),
      _CollectionDetails(
        'Recently Played',
        'bridal-veil-fall.jpg',
        page: AlbumListScreen(
          future: () => Repository().album.recent(),
          title: 'Recently Played',
        ),
      ),
      _CollectionDetails('By Decade', 'clock.jpg', page: DecadeScreen()),
      _CollectionDetails('By Genre', 'symphony-hall.jpg', page: GenreScreen()),
      _CollectionDetails('By Artist', 'brushes.jpg', page: ArtistsScreen()),
      _CollectionDetails('Alphabetical', 'typewriter.jpg',
          page: AlphabetScreen()),
    ];

    return SizedBox(
      height: 280,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          childAspectRatio: 1 / 1.2,
        ),
        itemCount: collections.length,
        itemBuilder: (context, int index) {
          return _CollectionCard(details: collections[index]);
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final _CollectionDetails details;

  const _CollectionCard({Key key, @required this.details})
      : assert(details != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 100,
          width: 180,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image:
                        AssetImage('lib/graphics/collections/${details.asset}'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                elevation: 0.0,
                child: Ink(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (details.page != null)
                        Navigator.push(context, details.route());
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(details.title, style: Theme.of(context).textTheme.subtitle1),
      ],
    );
  }
}

class _CollectionDetails {
  final String title;
  final String asset;
  final Widget page;

  const _CollectionDetails(this.title, this.asset, {this.page});

  PageRouteBuilder route() {
    return PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) {
        return page ?? Container();
      },
      transitionsBuilder:
          (___, Animation<double> animation, ____, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
    );
  }
}
