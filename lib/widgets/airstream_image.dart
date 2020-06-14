import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/models/provider_response.dart';
import 'package:flutter/material.dart';

class AirstreamImage extends StatelessWidget {
  const AirstreamImage({
    Key key,
    this.coverArt,
    this.songId,
    this.isHiDef = false,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  })  : assert(coverArt == null ? songId != null : true),
        assert(songId == null ? coverArt != null : true),
        super(key: key);

  final String coverArt;
  final int songId;
  final bool isHiDef;
  final BoxFit fit;
  final width;
  final height;

  Future _getFuture() {
    if (coverArt != null) {
      return Repository().image.fromArt(coverArt);
    } else {
      return Repository().image.fromSongId(songId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getFuture(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final imageResponse = snapshot.data;
          assert(imageResponse is ProviderResponse);

          if (imageResponse.status == DataStatus.ok) {
            return Container(
              height: height,
              width: width,
              child: Image.file(imageResponse.data, fit: fit),
            );
          } else {
            return Container(
              height: height,
              width: width,
              padding: const EdgeInsets.all(16),
              child: Image.asset('lib/graphics/album.png', fit: fit),
            );
          }
        } else {
          return Container(
            height: height,
            width: width,
            child: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
