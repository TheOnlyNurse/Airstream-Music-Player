import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../common/error/error_screen.dart';
import '../../../common/repository/album_repository.dart';
import '../../../common/widgets/sliver_close_bar.dart';
import '../../../global_assets.dart';

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
        child: FutureBuilder<Either<String, List<int>>>(
          future: albumRepository.decades(),
          builder: (context, snapshot) {
            switch(snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                return snapshot.data.fold(
                      (error) => ErrorScreen(message: error),
                      (decades) => _DecadesGridScreen(
                    decades: decades,
                    albumRepository: albumRepository,
                  ),
                );
              default:
                return const ErrorScreen(message: 'Snapshot error.');
            }
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
      physics: WidgetProperties.scrollPhysics,
      slivers: <Widget>[
        const SliverCloseBar(),
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
                    arguments: [() => albumRepository.decade(decades[index]), "${decades[index]}'s"],
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
  final void Function() onTap;

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
            child: Center(child: Text("$decade's", style: style)),
          ),
        ),
      ),
    );
  }
}
