import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SearchBar(),
      pinned: false,
      floating: true,
    );
  }
}

class _SearchBar extends SliverPersistentHeaderDelegate {
  final double barHeight = 65.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
                elevation: 9.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text('Search'),
                  onTap: () =>
                      Navigator.of(context, rootNavigator: true).pushNamed('/search'),
                  trailing: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pushNamed('/settings'),
                  ),
                )),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => barHeight;

  @override
  double get minExtent => barHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
