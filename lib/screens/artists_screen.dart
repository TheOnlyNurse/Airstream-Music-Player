import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/response/artist_response.dart';
import 'package:airstream/widgets/alpha_grid_view.dart';
import 'package:airstream/widgets/artist_circle.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Repository().artist.byAlphabet(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final ArtistResponse response = snapshot.data;
              if (response.hasData) {
                response.artists.sort((a, b) => a.name.compareTo(b.name));
                return AlphabeticalGridView(
                  headerStrings: response.artists.map((e) {
                    return e.name;
                  }).toList(),
                  builder: (start, end) {
                    final list = response.artists.sublist(start, end);
                    return SliverPadding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 30.0),
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
                              artist: list[index],
                            );
                          },
                          childCount: list.length,
                        ),
                      ),
                    );
                  },
                  leading: <Widget>[SliverCloseBar()],
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
