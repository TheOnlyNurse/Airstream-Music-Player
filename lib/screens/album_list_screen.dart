import 'package:airstream/widgets/error_widgets.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:airstream/widgets/sliver_close_bar.dart';
import 'package:flutter/material.dart';

class AlbumListScreen extends StatelessWidget {
  final Function() future;
  final String title;

  const AlbumListScreen({Key key, this.future, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: future(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final response = snapshot.data;
              if (response.hasNoData) {
                return ErrorScreen(response: response);
              }

              return CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverCloseBar(),
                  if (title == null) SliverToBoxAdapter(
                      child: SizedBox(height: 12)),
                  if (title != null) _Title(title: title),
                  SliverAlbumGrid(albumList: response.data),
                ],
              );
            }

            return Column(
              children: <Widget>[
                _CloseButton(),
                Expanded(child: Center(child: CircularProgressIndicator())),
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
        constraints: BoxConstraints.tightFor(
          width: 60,
          height: 60,
        ),
        onPressed: () => Navigator.pop(context),
        child: Icon(Icons.close),
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
        child: Text(title, style: Theme
            .of(context)
            .textTheme
            .headline4),
      ),
    );
  }
}
