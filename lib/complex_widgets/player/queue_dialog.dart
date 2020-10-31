import '../../complex_widgets/player/player_queue.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class QueueDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return SimpleDialog(
			title: Text('Queue', style: Theme.of(context).textTheme.headline5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      children: <Widget>[
        SizedBox(
					height: math.max(media.height - 250, 250),
          width: math.max(media.height - 50, 250),
          child: PlayerQueue(),
        )
      ],
    );
  }
}
