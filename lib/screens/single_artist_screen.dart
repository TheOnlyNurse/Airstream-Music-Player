import 'package:airstream/bloc/single_artist_bloc.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/models/image_adapter.dart';
import 'package:airstream/repository/album_repository.dart';
import 'package:airstream/repository/artist_repository.dart';
import '../complex_widgets/airstream_image.dart';
import '../complex_widgets/horizontal_artist_grid.dart';
import '../complex_widgets/sliver_card_grid.dart';
import '../complex_widgets/song_list/sliver_song_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class SingleArtistScreen extends StatelessWidget {
  final Artist artist;

  SingleArtistScreen({this.artist});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return SingleArtistBloc(
          albumRepository: GetIt.I.get<AlbumRepository>(),
          artistRepository: GetIt.I.get<ArtistRepository>(),
        )..add(SingleArtistAlbums(artist: artist));
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: BlocBuilder<SingleArtistBloc, SingleArtistState>(
          builder: (context, state) {
            if (state is SingleArtistSuccess) {
              return CustomScrollView(
                physics: BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  _AppBar(artist: artist),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (state.songs != null) _SliverTitle(title: 'Top Songs'),
                  if (state.songs != null) SliverSongList(songs: state.songs),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  _SliverTitle(title: 'Albums'),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverAlbumGrid(albumList: state.albums),
                  if (state.similarArtists != null)
                    _SliverTitle(title: 'Similar'),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (state.similarArtists != null)
                    _SimilarArtists(artists: state.similarArtists),
                ],
              );
            } else {
              return _OtherStates(state: state);
            }
          },
        ),
      ),
    );
  }
}

class _SimilarArtists extends StatelessWidget {
  final List<Artist> artists;

  const _SimilarArtists({Key key, @required this.artists})
      : assert(artists != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: HorizontalArtistGrid(
        artists: artists,
        onTap: (artist) {
          Navigator.pushNamed(
            context,
            'library/singleArtist',
            arguments: artist,
          );
        },
      ),
    );
  }
}

class _SliverTitle extends StatelessWidget {
  final String title;

  const _SliverTitle({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(title, style: Theme.of(context).textTheme.headline4),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final Artist artist;

  const _AppBar({Key key, this.artist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      stretch: true,
      stretchTriggerOffset: 200,
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child:
                Text(artist.name, style: Theme.of(context).textTheme.headline4),
          ),
        ),
        centerTitle: true,
        stretchModes: [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            AirstreamImage(
              adapter: ImageAdapter(artist: artist, isHiDef: true),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black26, Colors.black26.withOpacity(0.5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
      automaticallyImplyLeading: false,
      title: _CloseButton(),
      titleSpacing: 0,
    );
  }
}

class _OtherStates extends StatelessWidget {
  final SingleArtistState state;

  const _OtherStates({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  Widget _processState(SingleArtistState state) {
    if (state is SingleArtistFailure) return state.error;
    if (state is SingleArtistInitial) return CircularProgressIndicator();
    return Text('Failed to read state: $state');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _CloseButton(),
        Expanded(child: Center(child: _processState(state))),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tightFor(width: 60, height: 60),
      onPressed: () => Navigator.pop(context),
      shape: CircleBorder(),
      child: Icon(Icons.close),
    );
  }
}
