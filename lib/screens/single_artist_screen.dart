import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

/// Internal Links
import '../bloc/single_artist_bloc.dart';
import '../data_providers/moor_database.dart';
import '../models/image_adapter.dart';
import '../repository/album_repository.dart';
import '../repository/artist_repository.dart';
import '../static_assets.dart';
import '../complex_widgets/horizontal_artist_grid.dart';
import '../complex_widgets/sliver_album_grid.dart';
import '../complex_widgets/song_list/sliver_song_list.dart';
import '../widgets/flexible_image_with_title.dart';

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
                physics: airstreamScrollPhysics,
                slivers: [
                  _AppBar(artist: artist),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  if (state.songs != null) _SliverTitle(title: 'Top Songs'),
                  if (state.songs != null) SliverSongList(songs: state.songs),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  _SliverTitle(title: 'Albums'),
                  SliverToBoxAdapter(child: SizedBox(height: 8)),
                  SliverAlbumGrid(
                    albumList: state.albums,
                    onTap: (album) => Navigator.pushReplacementNamed(
                        context,
                        'library/singleAlbum',
                        arguments: album,
                      ),
                  ),
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
      flexibleSpace: FlexibleImageWithTitle(
        title: AutoSizeText(
          artist.name,
          style: Theme.of(context).textTheme.headline4,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        adapter: ImageAdapter(artist: artist, isHiDef: true),
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
