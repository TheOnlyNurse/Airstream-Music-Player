import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import '../bloc/player_controls_bloc.dart';
import '../../../common/providers/repository/repository.dart';
import '../widgets/play_button.dart';

class PlayerControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final disabledColor = Theme.of(context).disabledColor;
    final enabledColor = Theme.of(context).iconTheme.color;

    bool _isPreviousEnabled(PlayerControlsState state) {
      switch (state) {
        case PlayerControlsState.noNext:
          return true;
          break;
        case PlayerControlsState.allControls:
          return true;
          break;
        default:
          return false;
      }
    }

    bool _isNextEnabled(PlayerControlsState state) {
      switch (state) {
        case PlayerControlsState.noPrevious:
          return true;
          break;
        case PlayerControlsState.allControls:
          return true;
          break;
        default:
          return false;
      }
    }

    return BlocProvider(
      create: (context) => PlayerControlsBloc(),
      child: BlocBuilder<PlayerControlsBloc, PlayerControlsState>(
        builder: (context, state) {
          final isPrevious = _isPreviousEnabled(state);
          final isNext = _isNextEnabled(state);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                shape: CircleBorder(),
                child: Icon(
                  Icons.skip_previous,
                  size: 40.0,
                  color: isPrevious ? enabledColor : disabledColor,
                ),
                onPressed:
                    isPrevious ? () => Repository().audio.previous() : null,
              ),
              PlayButton(),
              RawMaterialButton(
                shape: CircleBorder(),
                child: Icon(
                  Icons.skip_next,
                  size: 40.0,
                  color: isNext ? enabledColor : disabledColor,
                ),
                onPressed: isNext ? () => Repository().audio.next() : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
