import 'package:airstream/bloc/single_artist_bloc.dart';
import 'package:airstream/events/single_artist_event.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/states/single_artist_state.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/album_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingleArtistScreen extends StatelessWidget {
  final Artist artist;

  SingleArtistScreen({this.artist});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SingleArtistBloc()..add(FetchArtistInfo(artist: artist)),
      child: BlocBuilder<SingleArtistBloc, SingleArtistState>(builder: (context, state) {
        if (state is ArtistScreenUninitialised) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ArtistScreenLoaded) {
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 256.0,
                flexibleSpace: AirstreamImage(
                  coverArt: artist.coverArt,
                  isHidef: true,
                ),
                backgroundColor: Theme.of(context).canvasColor,
                leading: RawMaterialButton(
                  onPressed: () => Navigator.of(context).pop(),
                  fillColor: Colors.transparent,
                  elevation: 0.0,
                  highlightElevation: 0.0,
                  shape: CircleBorder(),
                  child: Icon(Icons.close),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200.0,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 2.0,
                    childAspectRatio: 1 / 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, int index) {
                      final album = state.albums[index];
                      return AlbumCardWidget(
                        album: album,
                        onTap: () => Navigator.of(context)
                            .pushNamed('library/singleAlbum', arguments: album),
                      );
                    },
                    childCount: state.albums.length,
                  ),
                ),
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
    );
  }
}
