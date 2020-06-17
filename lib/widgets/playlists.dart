import 'package:airstream/bloc/playlists_library_bloc.dart';
import 'package:airstream/widgets/playlist_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Playlists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistsLibraryBloc()..add(PlaylistsLibraryEvent.fetch),
      child: BlocBuilder<PlaylistsLibraryBloc, PlaylistsLibraryState>(
        builder: (context, state) {
          if (state is PlaylistsLibrarySuccess) {
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, int index) {
                  return PlaylistTile(playlist: state.playlistArray[index]);
                },
                childCount: state.playlistArray.length,
              ),
            );
          }
          if (state is PlaylistsLibraryInitial) {
            return SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
          }
          if (state is PlaylistsLibraryFailure) {
            return SliverToBoxAdapter(child: Center(child: state.error));
          }
          return SliverToBoxAdapter(child: Center(child: Text('Error reading state')));
        },
      ),
    );
  }
}
