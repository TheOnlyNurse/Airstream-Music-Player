import 'package:airstream/bloc/playlists_screen_bloc.dart';
import 'package:airstream/widgets/playlist_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({Key key}) : super(key: key);

  _PlaylistsScreenState createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen>
    with AutomaticKeepAliveClientMixin<PlaylistsScreen> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => PlaylistsScreenBloc()..add(PlaylistsScreenEvent.fetch),
      child: BlocBuilder<PlaylistsScreenBloc, PlaylistsScreenState>(
        builder: (context, state) {
          if (state is PlaylistsScreenSuccess) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: state.playlistArray.length,
                itemBuilder: (context, int index) {
                  return PlaylistTile(playlist: state.playlistArray[index]);
                },
              ),
            );
          }
          if (state is PlaylistsScreenInitial) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is PlaylistsScreenFailure) {
            return Center(child: state.error);
          }
          return Center(child: Text('Error reading state'));
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
