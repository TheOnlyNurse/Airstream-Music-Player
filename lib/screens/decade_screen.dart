import 'package:airstream/models/repository_response.dart';
import 'package:airstream/repository/album_repository.dart';
import '../complex_widgets/error_widgets.dart';
import '../complex_widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class DecadeScreen extends StatelessWidget {
  const DecadeScreen({Key key, @required this.albumRepository})
      : assert(albumRepository != null),
        super(key: key);

  final AlbumRepository albumRepository;

  void openDecade(BuildContext context, int decade) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: albumRepository.decades(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final ListResponse<int> response = snapshot.data;

              if (response.hasData) {
                return _DecadesGridScreen(
                  decades: response.data,
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

class _DecadesGridScreen extends StatelessWidget {
  const _DecadesGridScreen({
    Key key,
    @required this.decades,
    @required this.albumRepository,
  })  : assert(decades != null),
        assert(albumRepository != null),
        super(key: key);

  final List<int> decades;
  final AlbumRepository albumRepository;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverCloseBar(),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _DecadeCard(
                decade: decades[index],
                index: index,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    'library/albumList',
                    arguments: () => albumRepository.decade(decades[index]),
                  );
                },
              );
            },
            childCount: decades.length,
          ),
        ),
      ],
    );
  }
}

class _DecadeCard extends StatelessWidget {
  const _DecadeCard({Key key, this.decade, this.index, this.onTap})
      : super(key: key);

  final int decade;
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
    final style = Theme.of(context).textTheme.headline4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 250,
        child: Card(
          color: _iterateThroughColors(),
          child: InkWell(
            onTap: onTap,
            child: Center(child: Text('$decade\'s', style: style)),
          ),
        ),
      ),
    );
  }
}
