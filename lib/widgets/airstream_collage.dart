import 'dart:io';
import 'package:airstream/data_providers/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

class AirstreamCollage extends StatelessWidget {
  const AirstreamCollage({
    Key key,
    this.songIds,
    this.columns = 2,
    this.rows = 2,
    this.fit = BoxFit.cover,
  })  : assert(songIds.length > 3),
        super(key: key);

  final List<int> songIds;
  final int columns;
  final int rows;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Repository().image.collage(songIds),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<File> images = snapshot.data;
          if (images != null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  children: List.generate(
                    images.length,
                    (index) {
                      return _FadeInImage(
                        image: images[index],
                        width: constraints.maxWidth / columns,
                        height: constraints.maxHeight / rows,
                        fit: fit,
                      );
                    },
                  ),
                );
              },
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('lib/graphics/album.png', fit: fit),
            );
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class _FadeInImage extends StatelessWidget {
  final File image;
  final double width;
  final double height;
  final fit;

  const _FadeInImage(
      {Key key, @required this.image, this.width, this.height, this.fit,})
      : assert(image != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 300);

    return PlayAnimation<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, child, value) {
        return AnimatedOpacity(
          opacity: value,
          duration: duration,
          child: Image.file(
            image,
            width: width,
            height: height,
            fit: fit,
          ),
        );
      },
    );
  }
}