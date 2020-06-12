import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/playlist_model.dart';
import 'package:airstream/widgets/song_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SongList extends StatelessWidget {
  final Album album;
  final Playlist playlist;
  final List<Widget> initialSlivers;

  SongList({this.initialSlivers, this.album, this.playlist});

  @override
  Widget build(BuildContext context) {
    SongListEvent _decideWhatToFetch() {
      if (this.album != null) return FetchAlbumSongs(this.album);
      if (this.playlist != null) return FetchPlaylistSongs(this.playlist);
      return FetchStarredSongs();
    }

    return BlocProvider(
      create: (context) => SongListBloc()..add(_decideWhatToFetch()),
      child: BlocBuilder<SongListBloc, SongListState>(
        builder: (context, state) {
          if (state is SongListLoaded) {
            final List<Widget> sliverList = [];
            if (this.initialSlivers != null) sliverList.addAll(this.initialSlivers);
            sliverList.add(
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 30.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, int index) {
                      if (index.isEven) {
                        final i = index ~/ 2;
                        return SongListTile(
                          song: state.songList[i],
                          onTap: () =>
                              Repository().playPlaylist(state.songList, index: i),
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
            );
            return CustomScrollView(
							physics: BouncingScrollPhysics(),
              slivers: sliverList,
            );
          }
          if (state is SongListUninitialised)
            return Center(child: CircularProgressIndicator());
          return Center(
            child: SizedBox(
              height: 80.0,
              child: Column(
                children: <Widget>[
                  Text('Hmm...I couldn\'t find any songs'),
                  RawMaterialButton(
                    onPressed: () => Navigator.of(context).pop(),
                    fillColor: Colors.transparent,
                    elevation: 0.0,
                    highlightElevation: 0.0,
                    constraints: BoxConstraints.tightFor(
                      width: 50,
                      height: 50,
                    ),
                    shape: CircleBorder(),
                    child: Icon(Icons.close),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
