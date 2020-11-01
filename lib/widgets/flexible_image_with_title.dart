/// External Packages
import 'package:flutter/material.dart';

/// Internal Links
import '../complex_widgets/airstream_image.dart';
import '../models/image_adapter.dart';

class FlexibleImageWithTitle extends StatelessWidget {
  const FlexibleImageWithTitle({Key key, this.title, this.adapter})
      : super(key: key);

  final String title;
  final ImageAdapter adapter;

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(title, style: Theme.of(context).textTheme.headline4),
        ),
      ),
      centerTitle: true,
      stretchModes: [
        StretchMode.zoomBackground,
        StretchMode.fadeTitle,
      ],
      background: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AirstreamImage(adapter: adapter),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.1),
                  Color.fromRGBO(0, 0, 0, 0.5),
                ],
                begin: Alignment(0, 1),
                end: Alignment(0, -1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
