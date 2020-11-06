import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import '../../bloc/mini_player_bloc.dart';
import '../../bloc/player_target_bloc.dart';

class PlayerActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
        builder: (context, state) {
      if (state is MiniPlayerInitial) {
        return SizedBox();
      }
      if (state is MiniPlayerSuccess) {
        return Draggable(
            child: _CustomButton(
              icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: () {
                context.bloc<MiniPlayerBloc>().add(MiniPlayerPlayPause());
              },
            ),
            axis: Axis.vertical,
            childWhenDragging: _CustomButton(fillColor: Colors.transparent),
            feedback: _CustomButton(icon: Icons.arrow_upward),
            onDragStarted: () {
              context.bloc<PlayerTargetBloc>().add(PlayerTargetEvent.dragStart);
            },
            onDraggableCanceled: (_, __) {
              context.bloc<PlayerTargetBloc>().add(PlayerTargetEvent.dragEnd);
            },
            onDragCompleted: () {
              context.bloc<PlayerTargetBloc>().add(PlayerTargetEvent.dragEnd);
            });
      }
      return _CustomButton(
        icon: Icons.error,
        fillColor: Theme.of(context).errorColor,
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
    return BlocBuilder<PlayerTargetBloc, PlayerTargetState>(
      builder: (context, state) {
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
                  onAccept: (data) {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed('/musicPlayer');
                  }),
            ]);
            break;
          default:
            return Visibility(
              visible: false,
              child: Container(),
            );
        }
      },
    );
  }
}

class _CustomButton extends StatelessWidget {
  final double width = 65.0;
  final double height = 65.0;
  final Function onPressed;
  final Color fillColor;
  final IconData icon;

  _CustomButton({this.icon, this.onPressed, this.fillColor});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      elevation: 2.0,
      shape: CircleBorder(),
      fillColor: fillColor != null ? fillColor : Theme.of(context).accentColor,
      constraints: BoxConstraints.tightFor(width: width, height: height),
      child: icon != null ? Icon(icon) : null,
      onPressed: onPressed,
    );
  }
}
