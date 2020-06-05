import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
          ),
          Center(
            child: Text('TODO: Search screen'),
          )
        ],
      )),
    );
  }
}
