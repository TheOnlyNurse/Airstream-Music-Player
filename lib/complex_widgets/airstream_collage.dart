import 'dart:io';
import 'package:airstream/repository/image_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
      future: GetIt.I.get<ImageRepository>().collage(songIds),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<File> images = snapshot.data;
          if (images != null) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  children: List.generate(
                    images.length,
                    (index) => throw UnimplementedError(),
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
