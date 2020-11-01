import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/models/repository_response.dart';
import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/static_assets.dart';
import 'package:airstream/repository/album_repository.dart';
import '../complex_widgets/album_card.dart';
import '../complex_widgets/alpha_grid_view.dart';
import '../complex_widgets/error_widgets.dart';
import '../widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({Key key, @required this.albumRepository})
      : assert(albumRepository != null),
        super(key: key);

  final AlbumRepository albumRepository;

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: albumRepository.byAlphabet(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final ListResponse<Album> response = snapshot.data;

              if (response.hasData) {
                return AlphabeticalGridView(
                  headerStrings: response.data.map((e) => e.title).toList(),
                  cacheKey: 'albumHeaders',
                  builder: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: airstreamAlbumsDelegate,
                    itemBuilder: (context, index) {
                      return AlbumCard(album: response.data[index]);
                    },
                    itemCount: response.data.length,
                    controller: _scrollController,
                  ),
                  controller: _scrollController,
                  leading: <Widget>[
                    SliverCloseBar(),
                  ],
                );
              }

              return ErrorText(error: response.error);
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
