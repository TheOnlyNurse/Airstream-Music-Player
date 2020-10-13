import 'package:airstream/models/repository_response.dart';
import 'package:airstream/repository/album_repository.dart';
import 'package:airstream/widgets/error_widgets.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({Key key, @required this.albumRepository})
      : assert(albumRepository != null),
        super(key: key);

  final AlbumRepository albumRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: albumRepository.allGenres(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final ListResponse<String> response = snapshot.data;

              if (response.hasData) {
                return _GenreSuccess(
                  genres: response.data,
                  albumRepository: albumRepository,
                );
              }

              if (response.hasError) {
                return ErrorScreen(response: response);
              }

              return ErrorText(error: snapshot.error.toString());
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _GenreSuccess extends StatelessWidget {
  const _GenreSuccess(
      {Key key, @required this.genres, @required this.albumRepository})
      : assert(genres != null),
        assert(albumRepository != null),
        super(key: key);

  final List<String> genres;
  final AlbumRepository albumRepository;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverCloseBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Text(
              'By Genre',
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
              childAspectRatio: 2 / 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, int index) {
                return _GenreRectangle(
                  genre: genres[index],
                  index: index,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      'library/albumList',
                      arguments: () => albumRepository.genre(genres[index]),
                    );
                  },
                );
              },
              childCount: genres.length,
            ),
          ),
        )
      ],
    );
  }
}

class _GenreRectangle extends StatelessWidget {
  const _GenreRectangle({
    Key key,
    this.genre,
    this.index,
    this.onTap,
  }) : super(key: key);

  final String genre;
  final int index;
  final Function onTap;

  Color _iterateThroughColors() {
    final colors = Colors.primaries;
    final evenDivisions = index ~/ colors.length;
    if (evenDivisions == 0) return colors[index][800];
    final adjustedIndex = index - evenDivisions * colors.length;
    return colors[adjustedIndex][800];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _iterateThroughColors(),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              genre,
              style: Theme.of(context).textTheme.subtitle2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
