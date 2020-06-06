import 'package:airstream/bloc/lib_artists_bloc.dart';
import 'package:airstream/events/lib_artists_event.dart';
import 'package:airstream/states/lib_artists_state.dart';
import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/complex_widgets/grid_with_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibraryArtistsBloc()..add(Fetch()),
      child: _ArtistsPage(),
    );
  }
}

class _ArtistsPage extends StatefulWidget {
  @override
  _ArtistsPageState createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<_ArtistsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryArtistsBloc, LibraryAlbumsState>(
      builder: (context, state) {
        if (state is Uninitialised) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is Error) {
          return Center(child: Text('Failed to fetch artists.'));
        }
        if (state is Loaded) {
          if (state.artists.isEmpty) {
            return Center(
              child: Text('No artists.'),
            );
          }
					return SliverGridWithStickHeader(modelList: state.artists);
        }
        return Center(
            child: Text("Oops! Something went wrong: current $state doesn\'t exist."));
      },
    );
  }
}
