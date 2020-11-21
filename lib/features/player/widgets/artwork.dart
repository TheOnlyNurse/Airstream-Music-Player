import 'package:flutter/material.dart';

import '../../../common/models/image_adapter.dart';
import '../../../common/providers/moor_database.dart';
import '../../../common/widgets/airstream_image.dart';

class PlayerArtwork extends StatelessWidget {
  const PlayerArtwork({Key key, @required this.song, List<Widget> overlay})
      : _overlay = overlay ?? const [],
        assert(song != null),
        super(key: key);

  final List<Widget> _overlay;
  final Song song;

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).backgroundColor;

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AirstreamImage(adapter: SongImageAdapter(song: song, isHiDef: true)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColor.withOpacity(0.4), bgColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _overlay,
          )
        ],
      ),
    );
  }
}