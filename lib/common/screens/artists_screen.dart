import 'package:flutter/material.dart';

import '../models/repository_response.dart';
import '../providers/moor_database.dart';
import '../repository/artist_repository.dart';
import '../static_assets.dart';
import '../widgets/alpha_grid_view.dart';
import '../widgets/artist_circle.dart';
import '../widgets/error_widgets.dart';

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
                    gridDelegate: WidgetProperties.artistsDelegate,
                    itemCount: response.data.length,
                    itemBuilder: (context, int index) {
                      return ArtistCircle(artist: response.data[index]);
                    },
                  ),
                );
              }

              if (response.hasError) {
                return ErrorScreen(response: response);
              }

              return Center(child: ErrorText(error: snapshot.error.toString()));
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
