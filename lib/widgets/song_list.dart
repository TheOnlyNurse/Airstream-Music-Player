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
  final List<Widget> leading;
  final Widget onError;

  SongList({@required this.onError, this.leading, this.album, this.playlist});

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
            if (this.leading != null) sliverList.addAll(this.leading);
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
          return onError;
        },
      ),
    );
  }
}
