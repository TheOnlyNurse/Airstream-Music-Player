import 'package:airstream/bloc/airstream_image_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AirstreamImage extends StatelessWidget {
  final String coverArt;
  final int songId;
  final bool isHiDef;
  final BoxFit fit;

  AirstreamImage({
    Key key,
    this.coverArt,
    this.songId,
    this.isHiDef = false,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AirstreamImageBloc()
        ..add(
          this.coverArt != null
              ? FetchImage(coverArt: coverArt, isHiDef: isHiDef)
              : this.songId != null
							? FetchImage(songId: songId, isHiDef: isHiDef)
							: throw Exception('No image detected by Airstream Image'),
        ),
      child: BlocBuilder<AirstreamImageBloc, AirstreamImageState>(
        builder: (context, state) {
          if (state is ImageLoaded) {
            return Image.file(
              state.image,
              fit: fit,
            );
          }
          if (state is ImageUninitialised) {
            return Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('lib/graphics/album.png'),
          );
        },
      ),
    );
  }
}
