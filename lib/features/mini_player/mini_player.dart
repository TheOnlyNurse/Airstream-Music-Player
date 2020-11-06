import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import 'bloc/mini_player_bloc.dart';

class MiniPlayerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void addToBloc(event) => context.bloc<MiniPlayerBloc>().add(event);

    return BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
      builder: (context, state) {
        return Visibility(
          visible: state is MiniPlayerShown,
          child: Draggable(
            child: _Button(
              icon: state is MiniPlayerShown && state.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              onPressed: () => addToBloc(MiniPlayerPlayPause()),
            ),
            axis: Axis.vertical,
            childWhenDragging: _Button(fillColor: Colors.transparent),
            feedback: _Button(icon: Icons.arrow_upward),
            onDragStarted: () => addToBloc(MiniPlayerDragStarted()),
            onDragEnd: (details) {
              addToBloc(MiniPlayerDragEnd(details.offset.dy));
            },
          ),
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  static const width = 65.0;
  static const height = 65.0;
  final Function onPressed;
  final Color fillColor;
  final IconData icon;

  const _Button({this.icon, this.onPressed, this.fillColor});

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
