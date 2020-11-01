import 'package:flutter/material.dart';

/// Internal
import 'package:airstream/widgets/circle_close_button.dart';

class SliverCloseBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      title: Container(
        width: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.transparent],
            stops: [0.2, 1],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: CircleCloseButton(),
      ),
    );
  }
}
