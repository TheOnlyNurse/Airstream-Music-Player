import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/response/album_response.dart';
import 'package:airstream/widgets/alpha_grid_view.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Repository().album.byAlphabet(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
							final AlbumResponse response = snapshot.data;
              if (snapshot.data.hasData) {
                return AlphabeticalGridView(
                  headerStrings: response.albums.map((e) {
                    return e.title;
                  }).toList(),
                  builder: (start, end) => SliverAlbumGrid(
										albumList: response.albums.sublist(start, end),
                  ),
                  leading: <Widget>[
                    SliverCloseBar(),
                  ],
                );
              }

              return Center(child: response.message);
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
