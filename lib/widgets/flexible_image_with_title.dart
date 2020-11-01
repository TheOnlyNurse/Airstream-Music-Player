import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
        child: AutoSizeText(
          title,
          style: Theme.of(context).textTheme.headline4,
          maxLines: 2,
          textAlign: TextAlign.center,
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
                  Color.fromRGBO(0, 0, 0, 0.5),
                  Color.fromRGBO(0, 0, 0, 0.1),
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
