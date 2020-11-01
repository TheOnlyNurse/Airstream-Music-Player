import 'package:airstream/bloc/starred_bloc.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/models/song_list_delegate.dart';
import 'package:airstream/repository/album_repository.dart';
import 'package:airstream/screens/album_list_screen.dart';
import '../complex_widgets/horizontal_album_grid.dart';
import '../complex_widgets/refresh_button.dart';
import 'package:airstream/data_providers/repository/repository.dart';
import '../complex_widgets/screen_transitions.dart';
import '../complex_widgets/sliver_album_grid.dart';
import '../complex_widgets/song_list/song_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class StarredScreen extends StatelessWidget {
  const StarredScreen({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StarredBloc(GetIt.I.get<AlbumRepository>())..add(StarredFetch()),
      child: BlocBuilder<StarredBloc, StarredState>(builder: (context, state) {
        if (state is StarredSuccess) {
          if (state.songs.isEmpty) {
            return _OnAlbumsOnly(albums: state.albums);
          } else {
            return _OnSongsAvailable(albums: state.albums, songs: state.songs);
          }
        } else {
          return _OtherStarredStates(state: state);
        }
      }),
    );
  }
}

class _OnAlbumsOnly extends StatelessWidget {
  final List<Album> albums;

  const _OnAlbumsOnly({Key key, @required this.albums})
      : assert(albums != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(child: _Heading()),
        SliverAlbumGrid(albumList: albums),
      ],
    );
  }
}

class _OnSongsAvailable extends StatelessWidget {
  final List<Album> albums;
  final List<Song> songs;

  const _OnSongsAvailable({Key key, this.albums, @required this.songs})
      : assert(songs != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SongList(
      delegate: SimpleSongList(initialSongs: songs, canRemoveStar: true),
      leading: <Widget>[
        SliverToBoxAdapter(child: _Heading()),
        if (albums != null)
          SliverToBoxAdapter(child: HorizontalAlbumGrid(albums: albums)),
        if (albums != null)
          SliverToBoxAdapter(
              child: _MoreAlbumsButton(
                  albumRepository: GetIt.I.get<AlbumRepository>())),
      ],
    );
  }
}

class _MoreAlbumsButton extends StatelessWidget {
  const _MoreAlbumsButton({Key key, @required this.albumRepository})
      : assert(albumRepository != null),
        super(key: key);

  final AlbumRepository albumRepository;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: RawMaterialButton(
        child: SizedBox(
          width: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 12),
              Text('Albums'),
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            fadeInSlideRoute(
              AlbumListScreen(
                title: 'Starred Albums',
                future: () => albumRepository.starred(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Starred',
            style: Theme.of(context).textTheme.headline4,
          ),
          RefreshButton(
            onPressed: () async {
              await GetIt.I.get<AlbumRepository>().updateStarred();
              await Repository().starred.update();
              context.bloc<StarredBloc>().add(StarredFetch());
            },
          ),
        ],
      ),
    );
  }
}

class _OtherStarredStates extends StatelessWidget {
  final StarredState state;

  const _OtherStarredStates({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  Widget _stateBasedWidget(StarredState state) {
    if (state is StarredInitial) return CircularProgressIndicator();
    if (state is StarredFailure) return state.error;
    return Text('Failed to read state: $state');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _Heading(),
        Expanded(child: Center(child: _stateBasedWidget(state))),
      ],
    );
  }
}
