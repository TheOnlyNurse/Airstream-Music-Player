import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/widgets/alpha_grid_view.dart';
import 'package:airstream/widgets/artist_circle.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Repository().artist.library(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.status == DataStatus.ok) {
                final List<Artist> artistList = snapshot.data.data;

                return AlphabeticalGridView(
                  headerStrings: artistList.map((e) => e.name).toList(),
                  builder: (start, end) => SliverPadding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1 / 1.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, int index) {
                          return ArtistCircle(
                            artist: artistList.sublist(start, end)[index],
                          );
                        },
                        childCount: artistList.sublist(start, end).length,
                      ),
                    ),
                  ),
                  leading: <Widget>[
                    SliverCloseBar(),
                  ],
                );
              }

              return Center(child: snapshot.data.message);
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
