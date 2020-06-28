import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: Repository().album.allGenres(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.status == DataStatus.ok) {
                final List<String> genreList = snapshot.data.data;

                return CustomScrollView(
                  physics: BouncingScrollPhysics(),
                  slivers: <Widget>[
                    SliverCloseBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'By Genre',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          childAspectRatio: 2 / 1,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, int index) {
                            return _GenreRectangle(genre: genreList[index], index: index);
                          },
                          childCount: genreList.length,
                        ),
                      ),
                    )
                  ],
                );
              }

              return Center(child: snapshot.data.message);
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _GenreRectangle extends StatelessWidget {
  const _GenreRectangle({Key key, this.genre, this.index}) : super(key: key);

  final String genre;
  final int index;

  Color _iterateThroughColors() {
    final colors = Colors.primaries;
    final evenDivisions = index ~/ colors.length;
    if (evenDivisions == 0) return colors[index][800];
    final adjustedIndex = index - evenDivisions * colors.length;
    return colors[adjustedIndex][800];
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        'library/albumList',
        arguments: Repository().album.genre(genre),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _iterateThroughColors(),
          borderRadius: BorderRadius.circular(8),
        ),
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
