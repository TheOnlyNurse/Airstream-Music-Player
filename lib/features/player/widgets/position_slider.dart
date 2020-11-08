import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/providers/repository/repository.dart';
import '../bloc/position_bloc.dart';

class PositionSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PositionBloc(),
      child: BlocBuilder<PositionBloc, PositionState>(
        builder: (context, state) {
          if (state is PositionSuccess) {
            return Column(
              children: <Widget>[
                Slider(
                  max: state.maxDuration,
                  value: state.currentPosition,
                  onChanged: (seconds) => Repository().audio.seek(seconds),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(state.currentText),
                      Text(state.maxText),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is PositionInitial || state is PositionLoading) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value:
                      state is PositionLoading ? state.percentage / 100 : null,
                ),
              ),
            );
          }

          return Center(
            child: Text('Could not read state: $state'),
          );
        },
      ),
    );
  }
}
