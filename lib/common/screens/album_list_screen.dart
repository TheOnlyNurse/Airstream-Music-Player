import 'package:airstream/common/error/error_screen.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

import '../providers/moor_database.dart';
import '../widgets/sliver_album_grid.dart';
import '../widgets/sliver_close_bar.dart';

class AlbumListScreen extends StatelessWidget {
  final Future<Either<String, List<Album>>> Function() future;
  final String title;

  const AlbumListScreen({Key key, this.future, this.title}) : super(key: key);

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
                  (albums) => CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverCloseBar(),
                      if (title == null)
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      if (title != null) _Title(title: title),
                      SliverAlbumGrid(albums: albums),
                    ],
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

class _Title extends StatelessWidget {
  final String title;

  const _Title({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(title, style: Theme.of(context).textTheme.headline4),
      ),
    );
  }
}
