import 'package:airstream/bloc/airstream_image_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AirstreamImage extends StatelessWidget {
  final String coverArt;
  final bool isHidef;
  final BoxFit fit;

  AirstreamImage(
      {@required this.coverArt, this.isHidef = false, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AirstreamImageBloc()
        ..add(FetchImage(
          coverArt: coverArt,
          isHiDef: isHidef,
        )),
      child:
          BlocBuilder<AirstreamImageBloc, AirstreamImageState>(builder: (context, state) {
        if (state is ImageUninitialised) {
          return Center(child: CircularProgressIndicator());
        }
        if (state is ImageLoaded) {
          return Image.file(
            state.image,
            fit: fit,
          );
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Image.asset('lib/graphics/album.png'),
        );
      }),
    );
  }
}
