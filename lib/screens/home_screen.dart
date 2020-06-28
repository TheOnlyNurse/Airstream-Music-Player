import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/widgets/home/collections.dart';
import 'package:airstream/widgets/home/playlists.dart';
import 'package:airstream/widgets/home/search_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final headlineStyle =
        Theme.of(context).textTheme.headline4.copyWith(fontWeight: FontWeight.bold);
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SearchBarLink(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Collections', style: headlineStyle),
                  _RefreshButton(
                    onPressed: () async {
                      await Repository().album.library(force: true);
                      await Repository().artist.library(force: true);
                    },
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: Collections()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Playlists', style: headlineStyle),
                  _RefreshButton(
                    onPressed: () => Repository().playlist.library(force: true),
                  )
                ],
              ),
            ),
          ),
          Playlists(),
          SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _RefreshButton extends StatelessWidget {
  final Function onPressed;

  const _RefreshButton({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      child: Icon(Icons.refresh),
      shape: CircleBorder(),
      constraints: BoxConstraints.tightFor(
        width: 50,
        height: 50,
      ),
      onPressed: onPressed,
    );
  }
}
