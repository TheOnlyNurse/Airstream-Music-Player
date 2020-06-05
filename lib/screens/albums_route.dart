import 'package:airstream/bloc/lib_albums_bloc.dart';
import 'package:airstream/events/lib_albums_event.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/states/lib_albums_state.dart';
import 'package:airstream/widgets/album_card.dart';
import 'package:airstream/widgets/custom_sticky_header.dart';
import 'package:airstream/widgets/search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlbumsRoute extends StatelessWidget {
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
  List<Widget> _createGridWithHeaders(List<Album> albums) {
    // The first widget should be the search bar widget
    List<Widget> sliverList = [
      SearchBarWidget(),
    ];

    // Go through artists for header and range pairs
    Map<String, Map> headerIndexes = {};
    String currHeader;
    for (var i = 0; i < albums.length; i++) {
      final String firstLetter = albums[i].name[0].toUpperCase();
      if (currHeader != firstLetter) {
        // To ensure headers being update exist
        if (headerIndexes.containsKey(currHeader)) {
          headerIndexes[currHeader]['endIndex'] = i - 1;
        }
        headerIndexes[firstLetter] = {
          'startIndex': i,
          'endIndex': albums.length - 1,
        };
        currHeader = firstLetter;
      }
    }

    // Build the grid with a header
    headerIndexes.forEach((letter, range) {
      sliverList.add(
        CustomSliverStickyHeader(
          title: letter,
          delegate: SliverChildBuilderDelegate(
            (context, int index) {
              final album = albums[index + range['startIndex']];
              return AlbumCardWidget(
                album: album,
                onTap: () => Navigator.of(context)
                    .pushNamed('library/singleAlbum', arguments: album),
              );
            },
            childCount: range['endIndex'] - range['startIndex'] + 1,
          ),
        ),
      );
    });
    return sliverList;
  }

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
          return CustomScrollView(
            slivers: _createGridWithHeaders(state.albums),
          );
        }
        return Center(
          child: Text('Fatal state error.'),
        );
      },
    );
  }
}
