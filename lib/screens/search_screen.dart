import 'package:airstream/bloc/search_screen_bloc.dart';
import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/widgets/artist_circle.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:airstream/widgets/titled_art_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;
  static final _textController = TextEditingController();

  const SearchScreen({Key key, this.navKey}) : super(key: key);

  Widget _buildSearchResults(BuildContext context, SearchState state) {
    Widget _title(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(title, style: Theme.of(context).textTheme.headline5),
      );
    }

    Widget _titleDivider() {
      return Divider(
        endIndent: 20,
        indent: 20,
      );
    }

    if (state is SearchLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (state is SearchFailure) {
      return Center(child: Text('Hmm...I couldn\'t find anything'));
    }

    if (state is SearchSuccess) {
      Widget _buildArtistCircles() {
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _title('Artists'),
              _titleDivider(),
              SizedBox(
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
            ],
          ),
        );
      }

      Widget _buildAlbumCards() {
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _title('Albums'),
              _titleDivider(),
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.albumList.length,
                  itemBuilder: (context, index) {
                    final album = state.albumList[index];
                    return AspectRatio(
                      aspectRatio: 1 / 1.25,
                      child: TitledArtCard(
                        artId: album.art,
                        title: album.title,
                        subtitle: album.artist,
                        onTap: () {
                          final navState = navKey.currentState;
                          if (navState.canPop()) {
                            navState.popUntil((route) => route.isFirst);
                          }
                          Navigator.pop(context);
                          _textController.clear();
                          navState.pushNamed('library/singleAlbum', arguments: album);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      return SongList(
        leading: <Widget>[
          if (state.artistList.isNotEmpty) _buildArtistCircles(),
          if (state.albumList.isNotEmpty) _buildAlbumCards(),
          if (state.songList.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  _title('Songs'),
                  _titleDivider(),
                ],
              ),
            ),
        ],
        type: SongListType.search,
        typeValue: state.songList,
      );
    }

    return Center(child: Text('Here to serve!'));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(),
      child: BlocBuilder<SearchBloc, SearchState>(builder: (context, state) {
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
                            onChanged: (query) => context.bloc<SearchBloc>().add(query),
                            autofocus: true,
                            maxLength: 25,
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              hintText: 'Search',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _textController.clear();
                                  context.bloc<SearchBloc>().add('');
                                },
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
