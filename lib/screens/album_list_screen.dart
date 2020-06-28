import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class AlbumListScreen extends StatelessWidget {
  const AlbumListScreen({Key key, @required this.future, this.title}) : super(key: key);

  final Future<ProviderResponse> future;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final ProviderResponse response = snapshot.data;

              if (response.status == DataStatus.ok) {
                final List<Album> albumList = snapshot.data.data;

                return CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverCloseBar(),
                    if (title != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child:
                              Text(title, style: Theme.of(context).textTheme.headline4),
                        ),
                      ),
                    SliverAlbumGrid(albumList: albumList),
                  ],
                );
              }

              return Column(
                children: <Widget>[
                  _CloseButton(),
                  Expanded(child: Center(child: response.message)),
                ],
              );
            }

            return Column(
              children: <Widget>[
                _CloseButton(),
                Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: RawMaterialButton(
        constraints: BoxConstraints.tightFor(
          width: 60,
          height: 60,
        ),
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.close),
      ),
    );
  }
}
