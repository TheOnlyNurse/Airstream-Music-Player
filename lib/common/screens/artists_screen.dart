import 'package:flutter/material.dart';

import '../error/widgets/error_widgets.dart';
import '../models/repository_response.dart';
import '../providers/moor_database.dart';
import '../repository/artist_repository.dart';
import '../widgets/alpha_grid_view.dart';
import '../widgets/artist_circle.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({Key key, @required this.artistRepository})
      : assert(artistRepository != null),
        super(key: key);

  final ArtistRepository artistRepository;

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ListResponse<Artist>>(
          future: artistRepository.byAlphabet(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final response = snapshot.data;

              if (response.hasData) {
                return AlphabeticalGridView(
                  controller: _scrollController,
                  headerStrings: response.data.map((e) => e.name).toList(),
                  cacheKey: 'artistHeaders',
                  builder: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 30.0),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 250,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1 / 1.2,
                    ),
                    itemCount: response.data.length,
                    itemBuilder: (context, int index) {
                      return ArtistCircle(artist: response.data[index]);
                    },
                  ),
                );
              }

              if (response.hasError) {
                return ErrorRepoResponseScreen(response: response);
              }

              return Center(child: CentredErrorText(error: snapshot.error.toString()));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
