import 'dart:io';

import 'package:airstream/data_providers/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AirstreamImage extends StatelessWidget {
  const AirstreamImage({
    Key key,
    this.coverArt,
    this.songId,
    this.isHiDef = false,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.animationLength = const Duration(milliseconds: 300),
  })  : assert(coverArt == null ? songId != null : coverArt != null),
        super(key: key);

  final String coverArt;
  final int songId;
  final bool isHiDef;
  final BoxFit fit;
  final double height;
  final double width;
  final Duration animationLength;

  Future _getFuture() {
    final _repo = Repository();
    if (coverArt != null) {
      return isHiDef
          ? _repo.image.highDef(coverArt)
          : _repo.image.lowDef(coverArt);
    } else {
      return _repo.image.fromSongId(songId, isHiDef: isHiDef);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getFuture(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final File response = snapshot.data;

          return PlayAnimation<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: animationLength,
            builder: (context, child, value) {
              return AnimatedOpacity(
                opacity: value,
                duration: animationLength,
                child: Container(
                  height: height,
                  width: width,
                  child: response != null
                      ? Image.file(response, fit: fit)
                      : Image.asset('lib/graphics/album.png', fit: fit),
                ),
              );
            },
          );
        }

        return Container(
          height: height,
          width: width,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
