import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/play_button.dart';
import 'package:airstream/widgets/song_position_slider.dart';
import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  final songPlaying = Repository().currentSong;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: ClipOval(
                    child: SizedBox(
                      width: 200.0,
                      height: 200.0,
                      child: AirstreamImage(
                        coverArt: songPlaying.coverArt,
                        isHidef: true,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    songPlaying.name,
                    style: Theme.of(context).textTheme.headline6,
                    softWrap: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    songPlaying.artistName,
                    style: Theme.of(context).textTheme.subtitle1,
                    softWrap: false,
                  ),
                ),
                SongPositionSlider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.skip_previous,
                        size: 48.0,
                      ),
                      onPressed: null,
                    ),
                    PlayButton(),
                    RawMaterialButton(
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.skip_next,
                        size: 48.0,
                      ),
                      onPressed: null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
