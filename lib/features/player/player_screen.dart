import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../common/error/widgets/error_widgets.dart';
import '../../common/repository/audio_repository.dart';
import 'bloc/player_bloc.dart';
import 'widgets/artwork.dart';
import 'widgets/header_buttons.dart';
import 'widgets/player_controls.dart';
import 'widgets/position_slider.dart';
import 'widgets/song_title.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlayerBloc()..add(PlayerFetch()),
      child: Material(
        child: SafeArea(
          child: BlocConsumer<PlayerBloc, PlayerState>(
            listener: (context, state) {
              if (state is PlayerSuccess && state.isFinished) {
                Navigator.of(context, rootNavigator: true).pop();
              }
            },
            builder: (_, state) {
              if (state is PlayerInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is PlayerSuccess) {
                return _Success(state: state);
              }

              return StateErrorScreen(message: state.toString());
            },
          ),
        ),
      ),
    );
  }
}

class _Success extends StatelessWidget {
  final PlayerSuccess state;
  const _Success({Key key, this.state}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        PlayerArtwork(
          song: state.song,
          overlay: <Widget>[
            const PlayerHeaderButtons(),
            PlayerSongTitle(state: state),
          ],
        ),
        const Spacer(),
        PositionSlider(audioRepository: GetIt.I.get<AudioRepository>()),
        const Spacer(),
        PlayerControls(audioRepository: GetIt.I.get<AudioRepository>()),
        const Spacer(),
      ],
    );
  }
}



