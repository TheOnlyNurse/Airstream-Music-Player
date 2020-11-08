import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Internal
import '../repository/image_repository.dart';

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
    return FutureBuilder<List<File>>(
      future: GetIt.I.get<ImageRepository>().collage(songIds),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final images = snapshot.data;
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
              child: Image.asset('lib/common/graphics/album.png', fit: fit),
            );
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
