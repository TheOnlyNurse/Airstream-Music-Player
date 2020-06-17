import 'file:///D:/Home/Documents/FlutterProjects/airstream/lib/widgets/playlists.dart';
import 'package:airstream/widgets/collections.dart';
import 'package:airstream/widgets/search_bar.dart';
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
              child: Text('Collections', style: headlineStyle),
            ),
          ),
          SliverToBoxAdapter(child: Collections()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text('Playlists', style: headlineStyle),
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
