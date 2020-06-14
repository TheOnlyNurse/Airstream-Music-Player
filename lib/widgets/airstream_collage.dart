import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:flutter/material.dart';

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
          final imageList = snapshot.data;
          if (imageList.status == DataStatus.ok) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  children: List.generate(
                    imageList.data.length,
                    (index) {
                      return Image.file(
                        imageList.data[index],
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
