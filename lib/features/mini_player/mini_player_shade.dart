import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import 'bloc/mini_player_bloc.dart';

class MiniPlayerShade extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MiniPlayerBloc, MiniPlayerState>(
      builder: (context, state) {
        return Visibility(
          visible: state is MiniPlayerShown && state.isMoving,
          child: Container(color: const Color.fromRGBO(0, 0, 0, 0.5)),
        );
      },
    );
  }
}
