import 'package:flutter/material.dart';

class SliverCloseBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Container(
        width: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).primaryColor, Colors.transparent],
            stops: [0.2, 1],
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: RawMaterialButton(
          constraints: BoxConstraints.tightFor(
            width: 50,
            height: 50,
          ),
          onPressed: () => Navigator.pop(context),
          child: Icon(Icons.close),
        ),
      ),
    );
  }
}
