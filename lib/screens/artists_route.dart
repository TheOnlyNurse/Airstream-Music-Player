import 'package:airstream/bloc/lib_artists_bloc.dart';
import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/events/lib_artists_event.dart';
import 'package:airstream/states/lib_artists_state.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/complex_widgets/alpha_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistsScreen extends StatelessWidget {
  static final controller = ScrollController();

  const ArtistsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBarBloc, NavigationBarState>(
      listener: (context, state) {
        if (state is NavigationBarLoaded && state.index == 1 && state.isDoubleTap) {
          controller.animateTo(
            0,
            duration: Duration(seconds: 2),
            curve: Curves.easeOutQuart,
          );
        }
      },
      child: BlocProvider(
        create: (context) => LibraryArtistsBloc()..add(Fetch()),
        child: BlocBuilder<LibraryArtistsBloc, LibraryAlbumsState>(
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
              return AlphabeticalGridView(
                controller: controller,
                modelList: state.artists,
              );
            }
            return Center(
                child:
                    Text("Oops! Something went wrong: current $state doesn\'t exist."));
          },
        ),
      ),
    );
  }
}
