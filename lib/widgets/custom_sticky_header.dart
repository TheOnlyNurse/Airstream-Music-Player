import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class CustomSliverStickyHeader extends StatelessWidget {
  final String title;
  final SliverChildBuilderDelegate delegate;

  CustomSliverStickyHeader({this.title, this.delegate});

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: Card(
                elevation: 9.0,
                shape: CircleBorder(),
                child: Center(
                  child: Text(
                    title,
                    textScaleFactor: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      sliver: SliverPadding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 30.0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 5.0,
            crossAxisSpacing: 2.0,
            childAspectRatio: 1 / 1,
          ),
          delegate: delegate,
        ),
      ),
    );
  }
}
