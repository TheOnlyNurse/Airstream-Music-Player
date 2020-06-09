import 'package:airstream/bloc/search_screen_bloc.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/song_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;

  const SearchScreen({Key key, this.navKey}) : super(key: key);

  Widget _buildSearchWidget(BuildContext context, SearchScreenState state) {
    if (state is SearchResultsLoaded) {
      return SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (state.artistList.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: state.artistList.length,
                  itemBuilder: (context, index) {
                    return _ArtistCircle(artist: state.artistList[index], navKey: navKey);
                  },
                ),
              ),
            if (state.songList.isNotEmpty)
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                child: ListView.builder(
                  itemCount: state.songList.length,
                  itemBuilder: (context, index) {
                    return SongListTile(
                      song: state.songList[index],
                      onTap: () => Repository().playPlaylist(state.songList),
                    );
                  },
                ),
              )
          ],
        ),
      );
    }
    if (state is LoadingSearchResults) {
      return Center(child: CircularProgressIndicator());
    }
    if (state is NoSearchResults) {
      return Center(child: Text('Hmm...I couldn\'t find anything'));
    }
    return Center(child: Text('I can feel you want to ask me something!'));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchScreenBloc(),
      child: BlocBuilder<SearchScreenBloc, SearchScreenState>(builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildSearchWidget(context, state),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Container(
                    height: 60,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      color: Theme.of(context).cardColor,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.search),
                        SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            onChanged: (query) =>
                                context.bloc<SearchScreenBloc>().add(query),
                            autofocus: true,
                            maxLength: 25,
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              hintText: 'Search',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ArtistCircle extends StatelessWidget {
  final Artist artist;
  final GlobalKey<NavigatorState> navKey;

  const _ArtistCircle({Key key, this.artist, this.navKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        navKey.currentState.pushNamed('library/singleArtist', arguments: artist);
      },
      child: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.hardEdge,
                child: AirstreamImage(coverArt: artist.coverArt),
              ),
            ),
            Text(artist.name),
          ],
        ),
      ),
    );
  }
}
