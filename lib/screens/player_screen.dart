import 'package:airstream/bloc/play_button_bloc.dart';
import 'package:airstream/bloc/player_bloc.dart';
import 'package:airstream/models/song_model.dart';
import 'package:airstream/widgets/player_controls.dart';
import 'package:airstream/widgets/song_position_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;

  const PlayerScreen({Key key, this.navKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final artTint = Theme.of(context).canvasColor;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    Widget _buildTitles(PlayerState state) {
      final songTitleStyle = Theme.of(context).textTheme.headline5.copyWith(
            fontWeight: FontWeight.bold,
          );
      final artistStyle = Theme.of(context).textTheme.subtitle1;

      Widget textColumn(Song song) {
        return Column(
          children: <Widget>[
            Text(song.title, style: songTitleStyle, softWrap: false),
            SizedBox(height: 6),
            Text(song.artist, style: artistStyle, softWrap: false),
          ],
        );
      }

      if (state is PlayerInitial) {
        return textColumn(state.song);
      }
      if (state is PlayerSuccess) {
        if (state.album != null) {
          return GestureDetector(
            onTap: () {
              final navState = navKey.currentState;
              if (navState.canPop()) {
                navState.popUntil((route) => route.isFirst);
              }
              Navigator.pop(context);
              navState.pushNamed('library/singleAlbum', arguments: state.album);
            },
            child: textColumn(state.song),
          );
        } else {
          return textColumn(state.song);
        }
      }
      return Text('State error');
    }

    Widget _buildImage(PlayerState state) {
      if (state is PlayerSuccess && state.image != null) {
        return Container(
          width: screenWidth,
          child: Image.file(state.image, fit: BoxFit.cover),
        );
      }
      return Container();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<PlayButtonBloc>(create: (context) => PlayButtonBloc()),
        BlocProvider<PlayerBloc>(
          create: (context) => PlayerBloc()..add(PlayerEvent.fetch),
        ),
      ],
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
                  child: BlocBuilder<PlayerBloc, PlayerState>(
                    builder: (context, state) {
                      return Stack(
                        children: <Widget>[
                          _buildImage(state),
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
                              _buildTitles(state),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
                Spacer(),
                SongPositionSlider(),
                Spacer(),
                PlayerControls(),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
