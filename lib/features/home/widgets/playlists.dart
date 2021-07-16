import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/error/widgets/error_widgets.dart';
import '../bloc/playlists_library_bloc.dart';
import 'playlist_tile.dart';

class Playlists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PlaylistsLibraryBloc()..add(PlaylistsLibraryEvent.fetch),
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
            return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()));
          }
          if (state is PlaylistsLibraryFailure) {
            return SliverToBoxAdapter(
              child: CentredErrorText(error: state.message),
            );
          }
          return const SliverToBoxAdapter(
              child: Center(child: Text('Error reading state')));
        },
      ),
    );
  }
}
