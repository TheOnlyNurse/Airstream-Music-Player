import 'package:airstream/bloc/search_bloc.dart';
import 'package:airstream/bloc/song_list_bloc.dart';
import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/widgets/artist_circle.dart';
import 'package:airstream/widgets/song_list.dart';
import 'package:airstream/widgets/album_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;

  const SearchScreen({Key key, this.navKey}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static final textController = TextEditingController();
  bool hiddenSearchBar = false;

  @override
  Widget build(BuildContext context) {
    Widget _title(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Text(title, style: Theme.of(context).textTheme.headline4),
      );
    }

    void _onTap(String route, dynamic argument) {
      final navState = widget.navKey.currentState;
      if (navState.canPop()) {
        navState.popUntil((route) => route.isFirst);
      }
      Navigator.pop(context);
      textController.clear();
      navState.pushNamed(route, arguments: argument);
    }

    List<Widget> _leadingSlivers(SearchSuccess state) {
      final slivers = <Widget>[];

      if (state.artistList.isNotEmpty) {
        slivers.add(
          _ArtistCircles(
            title: _title('Artists'),
            artistList: state.artistList,
            onTap: (artist) => _onTap('library/singleArtist', artist),
          ),
        );
      }

      if (state.albumList.isNotEmpty) {
        slivers.add(_AlbumCards(
          title: _title('Albums'),
          albumList: state.albumList,
          onTap: (album) => _onTap('library/singleAlbum', album),
        ));
      }

      return slivers;
    }

    return BlocProvider(
      create: (context) => SearchBloc(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              if (!hiddenSearchBar) _SearchBar(textController: textController),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchSuccess) {
                      return SongList(
                        type: SongListType.search,
                        typeValue: state.songList,
                        leading: _leadingSlivers(state),
                        title: _title('Songs'),
                        onSelection: (hasSelection) {
                          print('hasSelection: $hasSelection');
                          if (hasSelection != hiddenSearchBar) {
                            setState(() {
                              hiddenSearchBar = hasSelection;
                            });
                          }
                        },
                      );
                    }

                    if (state is SearchInitial) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Text('Here to serve'),
                        ),
                      );
                    }

                    if (state is SearchLoading) {
                      return Center(
                        child: SingleChildScrollView(
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      );
                    }

                    if (state is SearchFailure) {
                      return Center(
                        child: SingleChildScrollView(
                          child: Text('Found no results'),
                        ),
                      );
                    }

                    return Center(
                      child: SingleChildScrollView(
                        child: Text('Could not read state'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController textController;
  final bool isHidden;

  const _SearchBar({this.textController, this.isHidden});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search),
            SizedBox(width: 35),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: textController,
                  onChanged: (query) =>
                      context.bloc<SearchBloc>().add(SearchQuery(query)),
                  autofocus: textController.value.text.length == 0 ? true : false,
                  maxLength: 25,
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: 'Search',
                  ),
                ),
              ),
            ),
            RawMaterialButton(
              child: Icon(Icons.clear, color: Colors.white),
              shape: CircleBorder(),
              constraints: BoxConstraints.tightFor(width: 35, height: 35),
              onPressed: () {
                if (textController.value.text.length == 0) {
                  Navigator.pop(context);
                } else {
                  textController.clear();
                  context.bloc<SearchBloc>().add(SearchQuery(''));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumCards extends StatelessWidget {
  final Widget title;
  final List<Album> albumList;
  final Function(Album) onTap;

  const _AlbumCards({Key key, this.title, this.albumList, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title,
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: albumList.length,
              itemBuilder: (context, index) {
                return AspectRatio(
                  aspectRatio: 1 / 1.25,
                  child: AlbumCard(album: albumList[index], onTap: onTap),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistCircles extends StatelessWidget {
  final Widget title;
  final List<Artist> artistList;
  final Function(Artist) onTap;

  const _ArtistCircles({Key key, this.title, this.artistList, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title,
          SizedBox(
            height: 180,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: artistList.length,
              itemBuilder: (context, index) {
                final artist = artistList[index];
                return AspectRatio(
                  aspectRatio: 0.8 / 1,
                  child: ArtistCircle(
                    artist: artist,
                    onTap: () => onTap(artist),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
