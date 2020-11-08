import 'package:flutter/material.dart';

import '../models/image_adapter.dart';
import 'airstream_image.dart';

class FlexibleImageWithTitle extends StatelessWidget {
  const FlexibleImageWithTitle({Key key, this.title, this.adapter})
      : super(key: key);

  final Widget title;
  final ImageAdapter adapter;

  @override
  Widget build(BuildContext context) {
    return FlexibleSpaceBar(
      // Gives a constant width, so that the auto adjusting text doesn't keep re-rendering.
      title: ConstrainedBox(
        constraints: BoxConstraints.tightFor(
          width: MediaQuery.of(context).size.width - 160,
        ),
        child: title,
      ),
      centerTitle: true,
      stretchModes: const [
        StretchMode.zoomBackground,
        StretchMode.fadeTitle,
      ],
      background: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Padding(
            // Stops the image from overflowing under the gradient.
            padding: const EdgeInsets.only(bottom: 1),
            child: AirstreamImage(adapter: adapter),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(0, 0, 0, 0),
                  Color.fromRGBO(8, 10, 40, 1),
                ],
                begin: Alignment(0, -1),
                end: Alignment(0, 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
