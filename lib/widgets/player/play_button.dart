import 'package:airstream/data_providers/repository/repository.dart';
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart' as assets;

class PlayButton extends StatelessWidget {
  final player = Repository().audio.audioPlayer;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: player.playerState,
      builder: (context, state) {
        return RawMaterialButton(
          elevation: 4.0,
          fillColor: Theme.of(context).accentColor,
          constraints: BoxConstraints.tightFor(width: 80.0, height: 80.0),
          shape: CircleBorder(),
          child: Icon(
            state.data == assets.PlayerState.play ? Icons.pause : Icons.play_arrow,
            size: 60.0,
          ),
          onPressed: () => player.playOrPause(),
        );
			},
		);
	}
}
