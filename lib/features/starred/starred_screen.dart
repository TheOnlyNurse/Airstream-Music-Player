import 'package:airstream/common/song_list/sliver_song_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../common/global_assets.dart';
import '../../common/providers/moor_database.dart';
import '../../common/repository/album_repository.dart';
import '../../common/repository/song_repository.dart';
import '../../common/widgets/error_widgets.dart';
import '../../common/widgets/horizontal_album_grid.dart';
import '../../common/widgets/refresh_button.dart';
import '../../common/widgets/sliver_album_grid.dart';
import 'bloc/starred_bloc.dart';

class StarredScreen extends StatelessWidget {
  const StarredScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StarredBloc, StarredState>(builder: (context, state) {
      if (state is StarredSuccess) {
        if (state.songs.isEmpty) {
          return _OnAlbumsOnly(albums: state.albums);
        } else {
          return _OnSongsAvailable(albums: state.albums, songs: state.songs);
        }
      } else {
        return _OtherStarredStates(state: state);
      }
    });
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
      physics: WidgetProperties.scrollPhysics,
      slivers: <Widget>[
        SliverToBoxAdapter(child: _Heading()),
        SliverAlbumGrid(albums: albums),
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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _Heading()),
        if (albums.isNotEmpty)
          SliverToBoxAdapter(child: HorizontalAlbumGrid(albums: albums)),
        if (albums.isNotEmpty)
          SliverToBoxAdapter(
              child: _MoreAlbumsButton(
                  albumRepository: GetIt.I.get<AlbumRepository>())),
        SliverSongList(songs: songs),
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
        onPressed: () {
          Navigator.pushNamed(
            context,
            'library/albumList',
            arguments: () => albumRepository.starred(),
          );
        },
        child: SizedBox(
          width: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              SizedBox(width: 12),
              Text('Albums'),
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
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
              await GetIt.I.get<AlbumRepository>().forceSyncStarred();
              await GetIt.I.get<SongRepository>().starred(forceSync: true);
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
    if (state is StarredInitial) return const  CircularProgressIndicator();
    if (state is StarredFailure) return ErrorText(error: state.message);
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
