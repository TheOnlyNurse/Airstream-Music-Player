import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/repository/audio_repository.dart';
import '../bloc/position_bloc.dart';

class PositionSlider extends StatelessWidget {
  const PositionSlider({Key key, @required this.audioRepository})
      : super(key: key);
  final AudioRepository audioRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PositionBloc(audioRepository: audioRepository),
      child: BlocBuilder<PositionBloc, PositionState>(
        builder: (context, state) {
          if (state is PositionSuccess) {
            return Column(
              children: <Widget>[
                Slider(
                  max: state.maxDuration,
                  value: state.currentPosition,
                  onChanged: (seconds) => audioRepository.seek(seconds),
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
