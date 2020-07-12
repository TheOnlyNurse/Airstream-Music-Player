import 'package:airstream/bloc/single_artist_bloc.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/widgets/close_text_button.dart';
import 'package:airstream/widgets/horizontal_artist_grid.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:airstream/widgets/song_list/song_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingleArtistScreen extends StatelessWidget {
  final Artist artist;

  SingleArtistScreen({this.artist});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SingleArtistBloc()..add(SingleArtistAlbums(artist: artist)),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: BlocBuilder<SingleArtistBloc, SingleArtistState>(
          builder: (context, state) {
            if (state is SingleArtistSuccess) {
              if (state.songs != null) {
                return _HasTopSongs(state: state);
              } else {
                return _NoTopSongs(state: state);
              }
            } else {
              return _OtherStates(state: state);
            }
          },
        ),
      ),
    );
  }
}

class _HasTopSongs extends StatelessWidget {
  final SingleArtistSuccess state;

  const _HasTopSongs({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SongList(
      delegate: SimpleSongList(initialSongs: state.songs),
      sliverTitle: _SliverTitle(title: 'Top Songs'),
      leading: <Widget>[
        _SliverAppBar(state: state),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
      ],
      trailing: <Widget>[
        _SliverTitle(title: 'Albums'),
        SliverAlbumGrid(albumList: state.albums),
        if (state.similarArtists != null) _SliverTitle(title: 'Similar'),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        if (state.similarArtists != null)
          _SliverSimilarArtists(artists: state.similarArtists),
      ],
    );
  }
}

class _NoTopSongs extends StatelessWidget {
  final SingleArtistSuccess state;

  const _NoTopSongs({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        _SliverAppBar(state: state),
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          sliver: _SliverTitle(title: 'Albums'),
        ),
        SliverAlbumGrid(albumList: state.albums),
        if (state.similarArtists != null) _SliverTitle(title: 'Similar'),
        SliverToBoxAdapter(child: SizedBox(height: 8)),
        if (state.similarArtists != null)
          _SliverSimilarArtists(artists: state.similarArtists),
      ],
    );
  }
}

class _SliverSimilarArtists extends StatelessWidget {
  final List<Artist> artists;

  const _SliverSimilarArtists({Key key, @required this.artists})
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

class _SliverAppBar extends StatelessWidget {
  final SingleArtistSuccess state;

  const _SliverAppBar({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  Widget _image(SingleArtistSuccess state) {
    if (state.image != null) {
      return Image.file(state.image, fit: BoxFit.cover);
    } else {
      return Padding(
        padding: const EdgeInsets.all(30),
        child: Image.asset('lib/graphics/album.png'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: _image(state),
      automaticallyImplyLeading: false,
      title: CloseTextButton(),
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
        CloseTextButton(),
        Expanded(child: Center(child: _processState(state))),
      ],
    );
  }
}
