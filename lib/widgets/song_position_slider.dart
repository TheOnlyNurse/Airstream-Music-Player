import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class SongPositionSlider extends StatelessWidget {
  final _assetsAudioPlayer = AssetsAudioPlayer.withId('airstream');

  _formatDuration(Duration d) => d.toString().substring(2, 7);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _assetsAudioPlayer.currentPosition,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Current position error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.active) {
          final Duration currPosition = snapshot.data;
          final maxDuration = _assetsAudioPlayer.current.value != null
              ? _assetsAudioPlayer.current.value.audio.duration + Duration(seconds: 1)
              : currPosition;
          return SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTickMarkColor: Theme.of(context).accentColor,
              inactiveTrackColor: Theme.of(context).disabledColor,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Column(
              children: <Widget>[
                Slider(
                  min: 0,
                  max: maxDuration.inSeconds.roundToDouble(),
                  value: currPosition.inSeconds.roundToDouble(),
                  onChanged: (seconds) =>
                      _assetsAudioPlayer.seek(Duration(seconds: seconds.round())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										children: <Widget>[
											Text(_formatDuration(currPosition)),
											Text(_formatDuration(maxDuration)),
										],
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: LinearProgressIndicator());
      },
    );
  }
}
