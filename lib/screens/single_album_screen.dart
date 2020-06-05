import 'package:airstream/bloc/single_album_bloc.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/events/single_album_event.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/states/single_album_state.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/song_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingleAlbumScreen extends StatelessWidget {
  final Album album;

  SingleAlbumScreen({this.album});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
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
                expandedHeight: 384.0,
                flexibleSpace: AirstreamImage(
                  coverArt: album.coverArt,
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
                padding: const EdgeInsets.only(bottom: 30.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, int index) {
                      if (index.isEven) {
                        final i = index ~/ 2;
                        return SongListTile(
                          song: state.songList[i],
                          tapCallback: () => Repository().createQueueAndPlay(
                            playlist: state.songList,
                            index: i,
                          ),
                        );
                      }
                      return Divider(
                        indent: 30.0,
                        endIndent: 30.0,
                      );
                    },
                    childCount: state.songList.length * 2 - 1,
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
