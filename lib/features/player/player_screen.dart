import 'package:airstream/common/global_assets.dart';
import 'package:airstream/common/models/image_adapter.dart';
import 'package:airstream/common/repository/audio_repository.dart';
import 'package:airstream/common/widgets/airstream_image.dart';
import 'package:airstream/common/widgets/error_widgets.dart';
import 'package:airstream/common/widgets/future_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../common/providers/moor_database.dart';
import '../../common/repository/album_repository.dart';
import 'bloc/player_bloc.dart';
import 'widgets/player_controls.dart';
import 'widgets/position_slider.dart';
import 'widgets/queue_dialog.dart';

part 'widgets/title.dart';

class PlayerScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;

  const PlayerScreen({Key key, this.navKey}) : super(key: key);

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
  const _Success({Key key, this.state}) : super(key: key);
  final PlayerSuccess state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _Artwork(
          song: GetIt.I.get<AudioRepository>().current,
          overlay: <Widget>[
            _HeaderButtons(),
            _SongTitle(state: state),
          ],
        ),
        const Spacer(),
        PositionSlider(
          audioRepository: GetIt.I.get<AudioRepository>(),
        ),
        const Spacer(),
        PlayerControls(
          audioRepository: GetIt.I.get<AudioRepository>(),
        ),
        const Spacer(),
      ],
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({Key key, @required this.song, List<Widget> overlay})
      : _overlay = overlay ?? const [],
        assert(song != null),
        super(key: key);

  final List<Widget> _overlay;
  final Song song;

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).backgroundColor;

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AirstreamImage(adapter: ImageAdapter(song: song, isHiDef: true)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColor.withOpacity(0.4), bgColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _overlay,
          )
        ],
      ),
    );
  }
}

class _HeaderButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        RawMaterialButton(
          constraints: const BoxConstraints.tightFor(width: 60, height: 60),
          shape: const CircleBorder(),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: const Icon(Icons.close),
        ),
        RawMaterialButton(
          constraints: const BoxConstraints.tightFor(width: 60, height: 60),
          shape: const CircleBorder(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return QueueDialog();
              },
            );
          },
          child: const Icon(Icons.queue_music),
        ),
      ],
    );
  }
}
