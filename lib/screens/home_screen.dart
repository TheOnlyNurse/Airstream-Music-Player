import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/widgets/home/collections.dart';
import 'package:airstream/widgets/home/playlists.dart';
import 'package:airstream/widgets/home/refresh_button.dart';
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
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Collections', style: headlineStyle),
                  RefreshButton(
                    onPressed: () async {
                      await Repository().album.update();
                      await Repository().artist.update();
                    },
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: Collections()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Playlists', style: headlineStyle),
                  RefreshButton(
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
