import 'package:airstream/bloc/lib_albums_bloc.dart';
import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/complex_widgets/alpha_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumsScreen extends StatefulWidget {
  const AlbumsScreen({Key key}) : super(key: key);

  _AlbumsScreenState createState() => _AlbumsScreenState();
}

class _AlbumsScreenState extends State<AlbumsScreen>
    with AutomaticKeepAliveClientMixin<AlbumsScreen> {
  static final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            if (state is AlbumGridLoaded) {
              if (state.albums.isEmpty) {
                return Center(
                  child: Text('No albums.'),
                );
              }
              return AlphabeticalGridView(
                controller: controller,
                modelList: state.albums,
              );
            }
            if (state is AlbumGridUninitialised) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is AlbumGridError) {
              return Center(child: state.error);
            }
            return Center(
              child: Text('Fatal state error.'),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
