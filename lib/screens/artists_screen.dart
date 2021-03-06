import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/models/repository_response.dart';
import 'package:airstream/models/static_assets.dart';
import 'package:airstream/repository/artist_repository.dart';
import 'package:airstream/widgets/alpha_grid_view.dart';
import 'package:airstream/widgets/artist_circle.dart';
import 'package:airstream/widgets/error_widgets.dart';
import 'package:flutter/material.dart';

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
        child: FutureBuilder(
          future: artistRepository.byAlphabet(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final ListResponse<Artist> response = snapshot.data;

              if (response.hasData) {
                return AlphabeticalGridView(
                  controller: _scrollController,
                  headerStrings: response.data.map((e) => e.name).toList(),
                  cacheKey: 'artistHeaders',
                  builder: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 30.0),
                    gridDelegate: airstreamArtistsDelegate,
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

              return Center(child: ErrorText(error: snapshot.error));
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
