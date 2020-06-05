import 'package:airstream/bloc/player_button_bloc.dart';
import 'package:airstream/bloc/player_target_bloc.dart';
import 'package:airstream/events/player_button_event.dart';
import 'package:airstream/states/player_button_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerButtonBloc, PlayerButtonState>(builder: (context, state) {
      if (state is NoMusic) {
        return Visibility(
          visible: false,
          child: FloatingActionButton(
            onPressed: null,
          ),
        );
      }
      if (state is MusicPlaying || state is MusicPaused) {
        return Draggable(
          child: (() {
            if (state is MusicPlaying) {
              return FloatingActionButton(
                onPressed: () => context.bloc<PlayerButtonBloc>().add(PauseSong()),
                child: Icon(Icons.pause),
                elevation: 2.0,
              );
            }
            return FloatingActionButton(
              onPressed: () => context.bloc<PlayerButtonBloc>().add(ResumeSong()),
              child: Icon(Icons.play_arrow),
              elevation: 2.0,
            );
          }()),
          axis: Axis.vertical,
          childWhenDragging: FloatingActionButton(
            onPressed: null,
            backgroundColor: Colors.transparent,
          ),
          feedback: FloatingActionButton(
            onPressed: null,
            backgroundColor: Theme.of(context).accentColor,
            child: Icon(Icons.arrow_upward),
          ),
          onDragStarted: () =>
              context.bloc<PlayerTargetBloc>().add(PlayerTargetEvent.dragStart),
          onDraggableCanceled: (vel, off) =>
              context.bloc<PlayerTargetBloc>().add(PlayerTargetEvent.dragEnd),
          onDragCompleted: () =>
              context.bloc<PlayerTargetBloc>().add(PlayerTargetEvent.dragEnd),
        );
      }
      if (state is DownloadingMusic) {
        return Container(
          height: 55.0,
          width: 55.0,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                  radius: 0.5,
                  stops: [state.percentage / 100, 1],
                  colors: [Theme.of(context).accentColor, Colors.transparent])),
        );
      }
      return FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.error_outline),
        backgroundColor: Theme.of(context).errorColor,
      );
    });
  }
}

/// Drag Target for the Music Player Floating Action Button (above)
///
/// This widget renders when the player button is moved, darkening the screen and
/// providing a target.
class PlayerButtonTarget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerTargetBloc, PlayerTargetState>(builder: (context, state) {
      switch (state) {
        case PlayerTargetState.visible:
          return Stack(children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black.withOpacity(0.5),
            ),
            DragTarget(
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: MediaQuery.of(context).size.height - 200,
                  width: MediaQuery.of(context).size.width,
                );
              },
              onWillAccept: (data) => true,
              onAccept: (data) =>
                  Navigator.of(context, rootNavigator: true).pushNamed('/musicPlayer'),
            ),
          ]);
          break;
        default:
          return Visibility(
            visible: false,
            child: Container(),
          );
      }
    });
  }
}
