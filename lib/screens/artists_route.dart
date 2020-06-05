import 'package:airstream/bloc/lib_artists_bloc.dart';
import 'package:airstream/events/lib_artists_event.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/states/lib_artists_state.dart';
import 'package:airstream/widgets/artist_card.dart';
import 'package:airstream/widgets/custom_sticky_header.dart';
import 'package:airstream/widgets/search_bar.dart';
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
  List<Widget> _createGridWithHeaders(List<Artist> artists) {
    // The first widget should be the search bar widget
    List<Widget> sliverList = [
      SearchBarWidget(),
    ];

    // Go through artists for header and range pairs
    Map<String, Map> headerIndexes = {};
    String currHeader;
    for (var i = 0; i < artists.length; i++) {
      final String firstLetter = artists[i].name[0].toUpperCase();
      if (currHeader != firstLetter) {
        // To ensure headers being update exist
        if (headerIndexes.containsKey(currHeader)) {
          headerIndexes[currHeader]['endIndex'] = i - 1;
        }
        headerIndexes[firstLetter] = {
          'startIndex': i,
          'endIndex': artists.length - 1,
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
              final artist = artists[index + range['startIndex']];
              return ArtistCardWidget(
                artist: artist,
                onTap: () => Navigator.of(context).pushNamed(
                  'library/singleArtist',
                  arguments: artist,
                ),
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
          return CustomScrollView(
            slivers: _createGridWithHeaders(state.artists),
          );
        }
        return Center(
            child: Text("Oops! Something went wrong: current $state doesn\'t exist."));
      },
    );
  }
}
