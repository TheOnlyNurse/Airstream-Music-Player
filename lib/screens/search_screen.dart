import 'package:airstream/bloc/search_screen_bloc.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/widgets/artist_circle.dart';
import 'package:airstream/widgets/song_list_tile.dart';
import 'package:airstream/widgets/titled_art_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatelessWidget {
	final GlobalKey<NavigatorState> navKey;
  static final _textController = TextEditingController();

  const SearchScreen({Key key, this.navKey}) : super(key: key);

  Widget _buildSearchResults(BuildContext context, SearchScreenState state) {
    if (state is LoadingSearchResults) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is NoSearchResults) {
      return Center(child: Text('Hmm...I couldn\'t find anything'));
    }

    if (state is SearchResultsLoaded) {
      Widget _buildArtistCircles() {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 180,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: state.artistList.length,
              itemBuilder: (context, index) {
                final artist = state.artistList[index];
                return ArtistCircle(
                  artist: artist,
                  onTap: () {
                    final navState = navKey.currentState;
                    if (navState.canPop()) {
                      navState.popUntil((route) => route.isFirst);
                    }
                    Navigator.pop(context);
                    _textController.clear();
                    navState.pushNamed('library/singleArtist', arguments: artist);
                  },
                );
              },
            ),
          ),
        );
      }

      Widget _buildAlbumCards() {
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.albumList.length,
              itemBuilder: (context, index) {
                final album = state.albumList[index];
                return TitledArtCard(
                  artId: album.art,
                  title: album.title,
                  subtitle: album.artist,
                  width: 150,
                  onTap: () {
                    final navState = navKey.currentState;
                    if (navState.canPop()) {
                      navState.popUntil((route) => route.isFirst);
                    }
                    Navigator.pop(context);
                    _textController.clear();
                    navState.pushNamed('library/singleAlbum', arguments: album);
                  },
                );
              },
            ),
          ),
        );
      }

      Widget _buildSongTiles() {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, int index) {
              return SongListTile(
                song: state.songList[index],
                onTap: () => Repository().playPlaylist([state.songList[index]]),
              );
            },
            childCount: state.songList.length,
          ),
        );
      }

      return CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          if (state.artistList.isNotEmpty) _buildArtistCircles(),
          if (state.albumList.isNotEmpty) _buildAlbumCards(),
          if (state.songList.isNotEmpty) _buildSongTiles(),
        ],
      );
    }

    return Center(child: Text('Here to serve!'));
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
											onPressed: () {
												Navigator.of(context, rootNavigator: true).pop();
												_textController.clear();
											},
                    ),
                  ),
                ),
                Expanded(
									child: _buildSearchResults(context, state),
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
														controller: _textController,
														onChanged: (query) =>
																context.bloc<SearchScreenBloc>().add(query),
														autofocus: true,
														maxLength: 25,
														decoration: InputDecoration(
															counterText: '',
															border: InputBorder.none,
															hintText: 'Search',
															suffixIcon: IconButton(
																onPressed: () => _textController.clear(),
																icon: Icon(Icons.clear),
															),
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
