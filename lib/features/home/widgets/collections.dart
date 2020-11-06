import 'package:flutter/material.dart';

/// Internal
import '../../../common/repository/album_repository.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/screens/album_list_screen.dart';
import '../../../common/screens/alphabet_screen.dart';
import '../../../common/screens/artists_screen.dart';
import '../../../common/screens/decade_screen.dart';
import '../../../common/screens/genre_screen.dart';

class Collections extends StatelessWidget {
  const Collections(
      {Key key,
      @required this.albumRepository,
      @required this.artistRepository})
      : assert(albumRepository != null),
        assert(artistRepository != null),
        super(key: key);

  final AlbumRepository albumRepository;
  final ArtistRepository artistRepository;

  @override
  Widget build(BuildContext context) {
    final collections = <_CollectionDetails>[
      _CollectionDetails('Random', 'woodtype.webp',
          page: AlbumListScreen(
            future: () => albumRepository.random(),
            title: 'Random',
          )),
      _CollectionDetails(
        'Recently Added',
        'vegetables.webp',
        page: AlbumListScreen(
          future: () => albumRepository.recentlyAdded(),
          title: 'Recently Added',
        ),
      ),
      _CollectionDetails(
        'Most Played',
        'girl.webp',
        page: AlbumListScreen(
          future: () => albumRepository.mostPlayed(),
          title: 'Most Played',
        ),
      ),
      _CollectionDetails(
        'Recently Played',
        'bridal-veil-fall.webp',
        page: AlbumListScreen(
          future: () => albumRepository.recentlyPlayed(),
          title: 'Recently Played',
        ),
      ),
      _CollectionDetails('By Decade', 'clock.webp',
          page: DecadeScreen(albumRepository: albumRepository)),
      _CollectionDetails('By Genre', 'symphony-hall.webp',
          page: GenreScreen(albumRepository: albumRepository)),
      _CollectionDetails('By Artist', 'brushes.webp',
          page: ArtistsScreen(
            artistRepository: artistRepository,
          )),
      _CollectionDetails('Alphabetical', 'typewriter.webp',
          page: AlphabetScreen(albumRepository: albumRepository)),
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
                    image: AssetImage(
                        'lib/common/graphics/collections/${details.asset}'),
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

  PageRouteBuilder route() => PageRouteBuilder(
    opaque: false,
    pageBuilder: (BuildContext context, _, __) {
      return page;
    },
    transitionsBuilder: (___, animation, ____, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-0.5, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      );
    },
  );
}
