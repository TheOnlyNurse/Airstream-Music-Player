import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import 'bloc/mini_player_bloc.dart';

class MiniPlayerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void blocAdd(MiniPlayerEvent event) {
      context.bloc<MiniPlayerBloc>().add(event);
    }

    return BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
      builder: (context, state) {
        return Visibility(
          visible: state is MiniPlayerShown,
          child: Draggable(
            axis: Axis.vertical,
            childWhenDragging: const _Button(fillColor: Colors.transparent),
            feedback: const _Button(icon: Icons.arrow_upward),
            onDragStarted: () => blocAdd(MiniPlayerDragStarted()),
            onDragEnd: (details) {
              blocAdd(MiniPlayerDragEnd(details.offset.dy));
            },
            child: _Button(
              icon: state is MiniPlayerShown && state.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              onPressed: () => blocAdd(MiniPlayerPlayPause()),
            ),
          ),
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  static const width = 65.0;
  static const height = 65.0;
  final void Function() onPressed;
  final Color fillColor;
  final IconData icon;

  const _Button({this.icon, this.onPressed, this.fillColor});

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      shape: const CircleBorder(),
      fillColor: fillColor ?? Theme.of(context).accentColor,
      constraints: const BoxConstraints.tightFor(width: width, height: height),
      onPressed: onPressed,
      child: icon != null ? Icon(icon) : null,
    );
  }
}
