import 'package:flutter/material.dart';

import '../models/repository_response.dart';
import '../providers/moor_database.dart';
import '../widgets/error_widgets.dart';
import '../widgets/sliver_album_grid.dart';
import '../widgets/sliver_close_bar.dart';

class AlbumListScreen extends StatelessWidget {
  final Future<ListResponse<Album>> Function() future;
  final String title;

  const AlbumListScreen({Key key, this.future, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<ListResponse<Album>>(
          future: future(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final response = snapshot.data;
              if (response.hasError) {
                return ErrorScreen(response: response);
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverCloseBar(),
                  if (title == null)
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  if (title != null) _Title(title: title),
                  SliverAlbumGrid(albums: response.data),
                ],
              );
            }

            return Column(
              children: <Widget>[
                _CloseButton(),
                const Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: RawMaterialButton(
        constraints: const BoxConstraints.tightFor(
          width: 60,
          height: 60,
        ),
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.close),
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
