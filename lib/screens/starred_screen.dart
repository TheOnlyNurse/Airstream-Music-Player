import 'package:airstream/bloc/lib_starred_bloc.dart';
import 'package:airstream/events/lib_starred_event.dart';
import 'package:airstream/states/lib_starred_state.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StarredScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StarredBloc()..add(FetchStarred()),
      child: _StarredPage(),
    );
  }
}

class _StarredPage extends StatefulWidget {
  @override
  _StarredPageState createState() => _StarredPageState();
}

class _StarredPageState extends State<_StarredPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StarredBloc, StarredState>(
        builder: (context, state) {
          if (state is Uninitialised) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is Error) {
            return Center(child: Text('Failed to fetch starred songs.'));
          }
          if (state is Loaded) {
        return CustomScrollView(
          slivers: <Widget>[
            SongList(songList: state.songs),
          ],
        );
      }
      return Center(
        child: Text('Fatal state error'),
      );
    });
  }
}
