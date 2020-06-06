import 'package:airstream/bloc/single_album_bloc.dart';
import 'package:airstream/events/single_album_event.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/states/single_album_state.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingleAlbumScreen extends StatelessWidget {
  final Album album;

  SingleAlbumScreen({this.album});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: BlocProvider(
        create: (context) => SingleAlbumBloc()..add(FetchAlbumInfo(album: album)),
        child: BlocBuilder<SingleAlbumBloc, SingleAlbumState>(builder: (context, state) {
          if (state is AlbumScreenUninitialised) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is AlbumInfoLoaded) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 400,
                  flexibleSpace: AirstreamImage(
                    coverArt: album.coverArt,
                    isHidef: true,
                  ),
                  leading: RawMaterialButton(
                    shape: CircleBorder(),
                    child: Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SongList(songList: state.songList),
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
