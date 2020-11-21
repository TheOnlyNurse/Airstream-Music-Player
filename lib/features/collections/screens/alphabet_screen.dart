import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../common/error/error_screen.dart';
import '../../../common/providers/moor_database.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/widgets/album_card.dart';
import '../../../common/widgets/alpha_grid_view.dart';
import '../../../common/widgets/sliver_close_bar.dart';
import '../../../global_assets.dart';

class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({Key key, @required this.albumRepository})
      : assert(albumRepository != null),
        super(key: key);

  final AlbumRepository albumRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Either<String, List<Album>>>(
          future: albumRepository.byAlphabet(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                return snapshot.data.fold(
                  (error) => ErrorScreen(message: error),
                  (albums) => _Success(albums: albums),
                );
              default:
                return const ErrorScreen(message: 'Snapshot error.');
            }
          },
        ),
      ),
    );
  }
}

class _Success extends StatelessWidget {
  const _Success({Key key, this.albums}) : super(key: key);

  final List<Album> albums;

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();

    return AlphabeticalGridView(
      headerStrings: albums.map((e) => e.title).toList(),
      cacheKey: 'albumHeaders',
      builder: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: WidgetProperties.albumsDelegate,
        itemBuilder: (context, index) {
          return AlbumCard(album: albums[index]);
        },
        itemCount: albums.length,
        controller: _scrollController,
      ),
      controller: _scrollController,
      leading: const <Widget>[SliverCloseBar()],
    );
  }
}
