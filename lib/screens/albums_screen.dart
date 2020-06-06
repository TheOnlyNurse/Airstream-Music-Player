import 'package:airstream/bloc/lib_albums_bloc.dart';
import 'package:airstream/events/lib_albums_event.dart';
import 'package:airstream/states/lib_albums_state.dart';
import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/complex_widgets/grid_with_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibraryAlbumsBloc()..add(Fetch()),
      child: _AlbumsPage(),
    );
  }
}

class _AlbumsPage extends StatefulWidget {
  @override
  _AlbumsPageState createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<_AlbumsPage> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryAlbumsBloc, LibraryAlbumsState>(
      builder: (context, state) {
        if (state is AlbumGridUninitialised) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is AlbumGridError) {
          return Center(child: Text('Failed to fetch albums.'));
        }
        if (state is AlbumGridLoaded) {
          if (state.albums.isEmpty) {
            return Center(
              child: Text('No albums.'),
            );
          }
					return SliverGridWithStickHeader(modelList: state.albums);
        }
        return Center(
          child: Text('Fatal state error.'),
        );
      },
    );
  }
}
