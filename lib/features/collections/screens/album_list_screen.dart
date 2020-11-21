import 'package:airstream/common/error/error_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../../../common/providers/moor_database.dart';
import '../../../common/widgets/sliver_album_grid.dart';
import '../../../common/widgets/sliver_close_bar.dart';

class AlbumListScreen extends StatelessWidget {
  final Future<Either<String, List<Album>>> Function() future;
  final String title;

  const AlbumListScreen({Key key, @required this.future, @required this.title})
      : assert(future != null),
        assert(title != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Either<String, List<Album>>>(
          future: future(),
          builder: (_, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                return snapshot.data.fold(
                  (error) => ErrorScreen(message: error),
                  (albums) => _Success(title: title, albums: albums),
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

class _Success extends StatelessWidget {
  const _Success({Key key, this.title, this.albums}) : super(key: key);

  final String title;
  final List<Album> albums;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        const SliverCloseBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(title, style: Theme.of(context).textTheme.headline4),
          ),
        ),
        SliverAlbumGrid(albums: albums),
      ],
    );
  }
}
