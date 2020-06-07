import 'package:airstream/bloc/play_button_bloc.dart';
import 'package:airstream/data_providers/repository.dart';
import 'package:airstream/widgets/airstream_image.dart';
import 'package:airstream/widgets/play_button.dart';
import 'package:airstream/widgets/song_position_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerScreen extends StatelessWidget {
  final songPlaying = Repository().currentSong;

  @override
  Widget build(BuildContext context) {
    final artTint = Theme.of(context).canvasColor;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => PlayButtonBloc(),
      child: BlocListener<PlayButtonBloc, PlayButtonState>(
        listener: (context, state) {
          if (state == PlayButtonState.audioStopped) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Container(
                  height: screenHeight / 2,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: screenWidth,
                        child: AirstreamImage(
                          coverArt: songPlaying.coverArt,
                          isHidef: true,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [artTint.withOpacity(0.4), artTint],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              RawMaterialButton(
                                constraints:
                                    BoxConstraints.tightFor(width: 60, height: 60),
                                shape: CircleBorder(),
                                child: Icon(Icons.close),
                                onPressed: () =>
                                    Navigator.of(context, rootNavigator: true).pop(),
                              ),
                              RawMaterialButton(
                                constraints:
                                    BoxConstraints.tightFor(width: 60, height: 60),
                                shape: CircleBorder(),
                                child: Icon(Icons.queue_music),
                                onPressed: () => null,
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            children: <Widget>[
                              Text(
                                songPlaying.title,
                                style: Theme.of(context).textTheme.headline5.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                softWrap: false,
                              ),
                              SizedBox(height: 6),
                              Text(
                                songPlaying.artist,
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .subtitle1,
                                softWrap: false,
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Spacer(),
                SongPositionSlider(),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RawMaterialButton(
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.skip_previous,
                        size: 40.0,
                      ),
                      onPressed: null,
                    ),
                    PlayButton(),
                    RawMaterialButton(
                      shape: CircleBorder(),
                      child: Icon(
                        Icons.skip_next,
                        size: 40.0,
                      ),
                      onPressed: null,
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
