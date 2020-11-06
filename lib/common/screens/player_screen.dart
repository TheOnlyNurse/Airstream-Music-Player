import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:simple_animations/simple_animations.dart';

/// Internal
import '../bloc/player_bloc.dart';
import '../providers/moor_database.dart';
import '../repository/album_repository.dart';
import '../repository/image_repository.dart';
import '../complex_widgets/player/player_controls.dart';
import '../complex_widgets/player/queue_dialog.dart';
import '../complex_widgets/player/position_slider.dart';

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
                  Spacer(),
                  PositionSlider(),
                  Spacer(),
                  PlayerControls(),
                  Spacer(),
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

  const _ArtWork({Key key, this.overlay, this.state})
      : assert(state != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    final animationLength = Duration(milliseconds: 300);
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      height: MediaQuery.of(context).size.height / 2,
      child: Stack(
        children: <Widget>[
          if (currentState is PlayerSuccess && currentState.image != null)
            PlayAnimation(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: animationLength,
              builder: (context, child, value) {
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
            SizedBox(height: 6),
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

    return Text('State error');
  }
}

class _HeaderButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        RawMaterialButton(
          constraints: BoxConstraints.tightFor(width: 60, height: 60),
          shape: CircleBorder(),
          child: Icon(Icons.close),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        RawMaterialButton(
          constraints: BoxConstraints.tightFor(width: 60, height: 60),
          shape: CircleBorder(),
          child: Icon(Icons.queue_music),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return QueueDialog();
              },
            );
          },
        ),
      ],
    );
  }
}
