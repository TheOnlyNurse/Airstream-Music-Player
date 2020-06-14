import 'package:airstream/bloc/lib_artists_bloc.dart';
import 'package:airstream/bloc/nav_bar_bloc.dart';
import 'package:airstream/states/nav_bar_state.dart';
import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/complex_widgets/alpha_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArtistsScreen extends StatefulWidget {
  const ArtistsScreen({Key key}) : super(key: key);

  _ArtistsScreenState createState() => _ArtistsScreenState();
}

class _ArtistsScreenState extends State<ArtistsScreen>
    with AutomaticKeepAliveClientMixin<ArtistsScreen> {
  static final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
        create: (context) => LibraryArtistsBloc()..add(AlbumListFetch()),
        child: BlocBuilder<LibraryArtistsBloc, AlbumListState>(
          builder: (context, state) {
            if (state is AlbumListSuccess) {
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
            if (state is AlbumListInitial) {
              return Center(child: CircularProgressIndicator());
            }
            if (state is AlbumListFailure) {
              return Center(child: state.error);
            }
            return Center(child: Text("Error reading state"));
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
