import 'package:flutter/material.dart';

import '../../../common/repository/audio_repository.dart';

class PlayButton extends StatelessWidget {
  const PlayButton({Key key, @required this.audioRepository}) : super(key: key);
  final AudioRepository audioRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioState>(
      initialData: audioRepository.audioState.valueWrapper.value,
      stream: audioRepository.audioState,
      builder: (context, state) {
        final isPlaying = state.data == AudioState.playing;

        return RawMaterialButton(
          elevation: 4.0,
          fillColor: Theme.of(context).accentColor,
          constraints: const BoxConstraints.tightFor(width: 80.0, height: 80.0),
          shape: const CircleBorder(),
          onPressed: () => audioRepository.playPause(),
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 60.0),
        );
      },
    );
  }
}
