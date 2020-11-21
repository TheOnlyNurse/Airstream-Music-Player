import 'package:airstream/common/error/error_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/repository/artist_repository.dart';
import '../../../common/widgets/alpha_grid_view.dart';
import '../../../common/widgets/artist_circle.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({Key key, @required this.artistRepository})
      : assert(artistRepository != null),
        super(key: key);

  final ArtistRepository artistRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Either<String, List<Artist>>>(
          future: artistRepository.byAlphabet(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                return snapshot.data.fold(
                  (error) => ErrorScreen(message: error),
                  (artists) => _AlphabetGridView(artists: artists),
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

class _AlphabetGridView extends StatelessWidget {
  const _AlphabetGridView({Key key, this.artists}) : super(key: key);

  final List<Artist> artists;

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();

    return AlphabeticalGridView(
      controller: _scrollController,
      headerStrings: artists.map((e) => e.name).toList(),
      cacheKey: 'artistHeaders',
      builder: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1 / 1.2,
        ),
        itemCount: artists.length,
        itemBuilder: (context, int index) {
          return ArtistCircle(artist: artists[index]);
        },
      ),
    );
  }
}
