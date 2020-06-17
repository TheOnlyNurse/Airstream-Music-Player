import 'package:airstream/bloc/single_artist_bloc.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingleArtistScreen extends StatelessWidget {
  final Artist artist;

  SingleArtistScreen({this.artist});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SingleArtistBloc()..add(SingleArtistFetch(artist: artist)),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child:
            BlocBuilder<SingleArtistBloc, SingleArtistState>(builder: (context, state) {
          if (state is SingleArtistInitial) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is SingleArtistSuccess) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 400.0,
                  backgroundColor: Theme.of(context).canvasColor,
                  flexibleSpace: AirstreamImage(
                    coverArt: artist.art,
                    isHiDef: true,
                  ),
                  leading: RawMaterialButton(
                    onPressed: () => Navigator.of(context).pop(),
                    fillColor: Colors.transparent,
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    shape: CircleBorder(),
                    child: Icon(Icons.close),
                  ),
                ),
                SliverAlbumGrid(
                  albumList: state.albums,
                ),
              ],
            );
          }
          return Center(
            child: SizedBox(
              height: 80.0,
              child: Column(
                children: <Widget>[
                  Text('Failed to fetch album information.'),
                  RawMaterialButton(
                    onPressed: () => Navigator.of(context).pop(),
                    fillColor: Colors.transparent,
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    shape: CircleBorder(),
                    child: Icon(Icons.close),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
