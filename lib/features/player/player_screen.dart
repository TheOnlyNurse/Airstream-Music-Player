import 'package:airstream/common/repository/audio_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_animations/simple_animations.dart';

import '../../common/providers/moor_database.dart';
import '../../common/repository/album_repository.dart';
import '../../common/repository/image_repository.dart';
import 'bloc/player_bloc.dart';
import 'widgets/player_controls.dart';
import 'widgets/position_slider.dart';
import 'widgets/queue_dialog.dart';

class PlayerScreen extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;

  const PlayerScreen({Key key, this.navKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return PlayerBloc(
          albumRepository: GetIt.I.get<AlbumRepository>(),
          imageRepository: GetIt.I.get<ImageRepository>(),
        )..add(PlayerFetch());
      },
      child: BlocConsumer<PlayerBloc, PlayerState>(
        listener: (context, state) {
          if (state is PlayerSuccess && state.isFinished) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  _ArtWork(
                    state: state,
                    overlay: <Widget>[
                      _HeaderButtons(),
                      _SongTitle(state: state, navKey: navKey),
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
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ArtWork extends StatelessWidget {
  final List<Widget> overlay;
  final PlayerState state;

  const _ArtWork({Key key, this.overlay, @required this.state})
      : assert(state != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    const animationLength = Duration(milliseconds: 300);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return SizedBox(
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        children: <Widget>[
          if (currentState is PlayerSuccess && currentState.image != null)
            PlayAnimation(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: animationLength,
              builder: (context, child, double value) {
                return AnimatedOpacity(
                  opacity: value,
                  duration: animationLength,
                  child: Image.file(
                    currentState.image,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                );
              },
            ),
          Container(
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
            children: overlay ?? [],
          )
        ],
      ),
    );
  }
}

class _SongTitle extends StatelessWidget {
  final PlayerState state;
  final GlobalKey<NavigatorState> navKey;

  const _SongTitle({Key key, this.state, this.navKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentState = state;

    Widget textColumn(Song song) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Text(
              song.title,
              style: Theme.of(context).textTheme.headline5.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              song.artist,
              style: Theme.of(context).textTheme.subtitle1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    if (currentState is PlayerInitial) {
      return textColumn(currentState.song);
    }
    if (currentState is PlayerSuccess) {
      if (currentState.album != null) {
        return GestureDetector(
          onTap: () {
            final navState = navKey.currentState;
            if (navState.canPop()) {
              navState.popUntil((route) => route.isFirst);
            }
            Navigator.pop(context);
            navState.pushNamed('library/singleAlbum',
                arguments: currentState.album);
          },
          child: textColumn(currentState.song),
        );
      } else {
        return textColumn(currentState.song);
      }
    }

    return const Text('State error');
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
