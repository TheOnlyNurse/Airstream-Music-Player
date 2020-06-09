import 'package:airstream/bloc/player_screen_image_bloc.dart' as screen;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerScreenImage extends StatelessWidget {
  final BoxFit fit;

  PlayerScreenImage({
    Key key,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          screen.PlayerScreenImageBloc()..add(screen.PlayerScreenImageEvent.fetchImage),
      child: BlocBuilder<screen.PlayerScreenImageBloc, screen.PlayerScreenImageState>(
        builder: (context, state) {
          if (state is screen.ImageLoaded) {
            return Image.file(
              state.image,
              fit: fit,
            );
          }
          if (state is screen.ImageUninitialised) {
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
