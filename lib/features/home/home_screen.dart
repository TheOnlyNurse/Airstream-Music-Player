import 'package:flutter/material.dart';

import '../../common/global_assets.dart';
import '../../common/repository/album_repository.dart';
import '../../common/repository/artist_repository.dart';
import '../../common/repository/playlist_repository.dart';
import '../../common/widgets/refresh_button.dart';
import 'widgets/collections.dart';
import 'widgets/playlists.dart';
import 'widgets/search_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key key,
    @required this.albumRepository,
    @required this.artistRepository,
    @required this.playlistRepository,
  })  : assert(albumRepository != null),
        assert(artistRepository != null),
        assert(playlistRepository != null),
        super(key: key);

  final AlbumRepository albumRepository;
  final ArtistRepository artistRepository;
  final PlaylistRepository playlistRepository;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CustomScrollView(
        physics: WidgetProperties.scrollPhysics,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SearchBarLink(),
          ),
          _SliverTitle(
            title: 'Collections',
            onRefresh: () async {
              await albumRepository.syncLibrary();
              await artistRepository.forceSync();
            },
          ),
          SliverToBoxAdapter(
              child: Collections(
            albumRepository: albumRepository,
            artistRepository: artistRepository,
          )),
          _SliverTitle(
            title: 'Playlist',
            onRefresh: () async => playlistRepository.forceSync(),
          ),
          Playlists(),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }
}

class _SliverTitle extends StatelessWidget {
  final String title;
  final Future<void> Function() onRefresh;

  const _SliverTitle({Key key, this.title, this.onRefresh}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headline4),
            RefreshButton(onPressed: () => onRefresh())
          ],
        ),
      ),
    );
  }
}
