import 'package:flutter/material.dart';

import '../../../common/repository/communication.dart';
import '../../../common/repository/repository.dart';

class PlayButton extends StatelessWidget {
  final _repository = Repository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: _repository.audio.playerState.value,
      stream: _repository.audio.playerState,
      builder: (context, state) {
        final isPlaying = state.data == AudioPlayerState.playing;

        return RawMaterialButton(
          elevation: 4.0,
          fillColor: Theme.of(context).accentColor,
          constraints: const BoxConstraints.tightFor(width: 80.0, height: 80.0),
          shape: const CircleBorder(),
          onPressed: () {
            if (isPlaying) {
              _repository.audio.pause();
            } else {
              _repository.audio.play();
            }
          },
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 60.0),
        );
      },
    );
  }
}
