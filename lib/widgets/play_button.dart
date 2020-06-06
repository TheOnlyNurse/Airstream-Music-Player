import 'package:airstream/bloc/play_button_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayButtonBloc, PlayButtonState>(
      builder: (context, state) {
        return RawMaterialButton(
          elevation: 4.0,
          fillColor: Theme.of(context).accentColor,
          constraints: BoxConstraints.tightFor(
            width: 80.0,
            height: 80.0,
          ),
          shape: CircleBorder(),
          child: Icon(
            state == PlayButtonState.audioPlaying ? Icons.pause : Icons.play_arrow,
            size: 60.0,
          ),
          onPressed: () => context.bloc<PlayButtonBloc>().add(PlayButtonEvent.playPause),
        );
      },
    );
  }
}
