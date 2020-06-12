import 'package:airstream/bloc/lib_albums_bloc.dart';
import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/events/lib_albums_event.dart';
import 'package:airstream/states/lib_albums_state.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/complex_widgets/alpha_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumsScreen extends StatelessWidget {
  static final controller = PageController();

  const AlbumsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBarBloc, NavigationBarState>(
      listener: (context, state) {
        if (state is NavigationBarLoaded && state.index == 2 && state.isDoubleTap) {
          controller.animateTo(
            0,
            duration: Duration(seconds: 2),
            curve: Curves.easeOutQuart,
          );
        }
      },
      child: BlocProvider(
        create: (context) => LibraryAlbumsBloc()..add(Fetch()),
        child: BlocBuilder<LibraryAlbumsBloc, LibraryAlbumsState>(
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
              return AlphabeticalGridView(
                  controller: controller, modelList: state.albums);
            }
            return Center(
              child: Text('Fatal state error.'),
            );
          },
        ),
      ),
    );
  }
}
