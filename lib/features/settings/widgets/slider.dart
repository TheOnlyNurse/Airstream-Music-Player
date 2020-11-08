import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Internal
import '../../../common/repository/communication.dart';
import '../bloc/slider_bloc.dart';

class SettingsSlider extends StatelessWidget {
  final SettingType type;
  final String title;

  const SettingsSlider({Key key, @required this.type, this.title})
      : assert(type != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SliderBloc()..add(SliderFetch(type)),
      child: BlocBuilder<SliderBloc, SliderState>(builder: (context, state) {
        if (state is SliderSuccess) {
          void sliderBloc(SliderEvent event) {
            context.bloc<SliderBloc>().add(event);
          }

          final headline = Theme.of(context).textTheme.subtitle1;

          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (title != null) Text(title, style: headline),
                    Text(state.value.floor().toString(), style: headline)
                  ],
                ),
              ),
              Slider(
                min: state.min,
                max: state.max,
                divisions: state.divisions,
                value: state.value,
                onChanged: (value) => sliderBloc(SliderUpdate(value)),
                onChangeEnd: (value) => sliderBloc(SliderFinished(value)),
              ),
            ],
          );
        }

        return const Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(),
          ),
        );
      }),
    );
  }
}
