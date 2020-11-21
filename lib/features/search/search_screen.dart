import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../common/providers/moor_database.dart';
import '../../common/repository/album_repository.dart';
import '../../common/repository/artist_repository.dart';
import '../../common/repository/song_repository.dart';
import '../../common/widgets/horizontal_album_grid.dart';
import '../../common/widgets/horizontal_artist_grid.dart';
import '../../common/widgets/song_tile.dart';
import '../../global_assets.dart';
import 'bloc/search_bloc.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _onTap(String route, dynamic argument) {
      if (libraryNavigator.currentState.canPop()) {
        libraryNavigator.currentState.popUntil((route) => route.isFirst);
      }
      Navigator.of(libraryNavigator.currentContext)
          .pushNamed(route, arguments: argument);
      Navigator.pop(context);
    }

    return BlocProvider(
      create: (context) {
        return SearchBloc(
          albumRepository: GetIt.I.get<AlbumRepository>(),
          artistRepository: GetIt.I.get<ArtistRepository>(),
          songRepository: GetIt.I.get<SongRepository>(),
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              _SearchBar(textController: _textController),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchSuccess) {
                      return _OnSearchSuccess(
                        state: state,
                        onTap: _onTap,
                        albumRepository: GetIt.I.get<AlbumRepository>(),
                      );
                    } else {
                      return _OtherSearchStates(state: state);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
            const Icon(Icons.search),
            const SizedBox(width: 35),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  controller: textController,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter(
                      RegExp("[a-zA-z ]"),
                      allow: true,
                    ),
                  ],
                  onChanged: (query) =>
                      context.read<SearchBloc>().add(SearchQuery(query)),
                  autofocus: textController.value.text.isEmpty,
                  maxLength: 25,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    hintText: 'Search',
                  ),
                ),
              ),
            ),
            RawMaterialButton(
              shape: const CircleBorder(),
              constraints: const BoxConstraints.tightFor(width: 35, height: 35),
              onPressed: () {
                if (textController.value.text.isEmpty) {
                  Navigator.pop(context);
                } else {
                  textController.clear();
                  context.read<SearchBloc>().add(const SearchQuery(''));
                }
              },
              child: const Icon(Icons.clear, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnSearchSuccess extends StatelessWidget {
  final SearchSuccess state;
  final Function(String route, dynamic argument) onTap;
  final AlbumRepository albumRepository;

  const _OnSearchSuccess({
    Key key,
    @required this.state,
    @required this.albumRepository,
    this.onTap,
  })  : assert(state != null),
        assert(albumRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget _title(String title) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(title, style: Theme.of(context).textTheme.headline4),
        ),
      );
    }

    List<Widget> _slivers() {
      final slivers = <Widget>[];

      if (state.artists.isNotEmpty) {
        slivers.addAll([
          _title('Artists'),
          SliverToBoxAdapter(
            child: HorizontalArtistGrid(
              artists: state.artists,
              onTap: (artist) {
                if (onTap != null) onTap('library/singleArtist', artist);
              },
            ),
          ),
        ]);
      }

      if (state.albums.isNotEmpty) {
        slivers.addAll([
          _title('Albums'),
          SliverToBoxAdapter(
            child: HorizontalAlbumGrid(
              albums: state.albums,
              onTap: (album) {
                if (onTap != null) onTap('library/singleAlbum', album);
              },
            ),
          ),
        ]);
      }

      if (state.songs.isNotEmpty) {
        slivers.addAll([
          _title('Songs'),
          _SongTiles(
            songs: state.songs,
            onTap: (song) async {
              (await albumRepository.byId(song.albumId)).fold(
                (error) => null,
                (album) {
                  if (onTap != null) onTap('library/singleAlbum', album);
                },
              );
            },
          ),
        ]);
      }

      return slivers;
    }

    return CustomScrollView(
      physics: WidgetProperties.scrollPhysics,
      slivers: _slivers(),
    );
  }
}

class _OtherSearchStates extends StatelessWidget {
  final SearchState state;

  const _OtherSearchStates({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  Widget _getStateText() {
    final currentState = state;
    if (currentState is SearchInitial) return const Text('Here to serve!');
    if (currentState is SearchLoading) {
      return const SizedBox(
        height: 60,
        width: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (currentState is SearchFailure) return const Text('Found no results.');
    // If no state could be found
    return const Text('Could not read state.');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: _getStateText(),
      ),
    );
  }
}

class _SongTiles extends StatelessWidget {
  final List<Song> songs;
  final Function(Song) onTap;

  const _SongTiles({Key key, this.songs, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
      (context, index) {
        return SongTile(
          song: songs[index],
          onTap: () => onTap != null ? onTap(songs[index]) : null,
        );
      },
      childCount: songs.length,
    ));
  }
}
