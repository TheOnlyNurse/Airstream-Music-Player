import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/provider_response.dart';
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
              if (snapshot.data.status == DataStatus.ok) {
                final List<Album> albumList = snapshot.data.data;

                return AlphabeticalGridView(
                  headerStrings: albumList.map((e) => e.title).toList(),
                  builder: (start, end) => SliverAlbumGrid(
                    albumList: albumList.sublist(start, end),
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
