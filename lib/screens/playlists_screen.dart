import 'package:airstream/bloc/playlists_screen_bloc.dart';
import 'package:airstream/widgets/playlist_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistsScreenBloc()..add(PlaylistsScreenEvent.fetch),
      child: BlocBuilder<PlaylistsScreenBloc, PlaylistsScreenState>(
        builder: (context, state) {
          if (state is PlaylistsLoaded) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: ListView.builder(
								physics: BouncingScrollPhysics(),
								itemCount: state.playlistArray.length,
								itemBuilder: (context, int index) {
									return PlaylistTile(
										playlist: state.playlistArray[index],
									);
								},
							),
						);
					}
					if (state is PlaylistsScreenError)
						return Center(child: Text('Error: ${state.message}'));
					if (state is PlaylistsUninitialised)
						return Center(child: CircularProgressIndicator());
					return Center(child: Text('Error: reading state'));
				},
			),
		);
	}
}
