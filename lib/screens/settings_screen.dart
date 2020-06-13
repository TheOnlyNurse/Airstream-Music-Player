import 'package:airstream/bloc/settings_bloc.dart';
import 'package:airstream/data_providers/server_provider.dart';
import 'package:airstream/data_providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  final isExpandedReference = [false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocProvider(
          create: (context) => SettingsBloc()..add(SettingsStarted()),
          child: BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              if (state is SettingsSuccess) {
                settingsBloc(event) => context.bloc<SettingsBloc>().add(event);
                final textStyle = Theme.of(context).textTheme.headline6;
                final customSliderTheme = SliderTheme.of(context).copyWith(
                  activeTickMarkColor: Theme.of(context).accentColor,
                  inactiveTrackColor: Theme.of(context).disabledColor,
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
                );

                ExpansionPanel _buildServerSettings() {
                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: isExpandedReference[0],
                    headerBuilder: (context, bool isExpanded) {
                      return ListTile(
                        title: Text('Server', style: textStyle),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ListTile(
                        title: Text('Prefetch'),
                        subtitle: Slider(
                          min: 0,
                          max: 3,
                          divisions: 3,
                          label: state.prefetch.toString(),
                          value: state.prefetch.toDouble(),
                          onChanged: (double value) => settingsBloc(SettingsChanging(
                            SettingsChangedType.prefetch,
                            value.round(),
                          )),
                          onChangeEnd: (double value) => settingsBloc(SettingsChanged(
                            SettingsChangedType.prefetch,
                            value.round(),
                          )),
                        ),
                      ),
                    ),
                  );
                }

                ExpansionPanel _buildStorageSettings() {
                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded: isExpandedReference[1],
                    headerBuilder: (context, bool isExpanded) {
                      return ListTile(
                        title: Text('Cache', style: textStyle),
                      );
                    },
                    body: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Text('Music Cache'),
                            subtitle: Slider(
                              min: 100,
                              max: 10000,
                              divisions: 99,
                              label: state.musicCacheSize.toString(),
                              value: state.musicCacheSize.toDouble(),
                              onChanged: (value) =>
                                  settingsBloc(SettingsChanging(
                                    SettingsChangedType.musicCache,
                                    value.round(),
                                  )),
                              onChangeEnd: (double value) =>
                                  settingsBloc(SettingsChanged(
                                    SettingsChangedType.musicCache,
                                    value.round(),
                                  )),
                            ),
                          ),
                          ListTile(
                            title: Text('Image Cache'),
                            subtitle: Slider(
                              min: 20,
                              max: 1000,
                              divisions: 98,
                              label: state.imageCacheSize.toString(),
                              value: state.imageCacheSize.toDouble(),
                              onChanged: (value) =>
                                  settingsBloc(SettingsChanging(
                                    SettingsChangedType.imageCache,
                                    value.round(),
                                  )),
                              onChangeEnd: (double value) =>
                                  settingsBloc(SettingsChanged(
                                    SettingsChangedType.imageCache,
                                    value.round(),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SliderTheme(
                    data: customSliderTheme,
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () =>
                                  Navigator.of(context, rootNavigator: true).pop(),
                            ),
                          ),
                        ),
                        Card(
                          child: SwitchListTile(
                            secondary: Icon(Icons.cloud_download),
                            title: Text('Go offline?'),
                            value: state.isOffline,
                            activeColor: Theme
                                .of(context)
                                .accentColor,
                            onChanged: (bool value) =>
                                context.bloc<SettingsBloc>().add(
                                    SettingsChanged(
                                        SettingsChangedType.isOffline, value)),
                          ),
                        ),
                        Card(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: ExpansionPanelList(
                            expansionCallback: (int index, bool isExpanded) {
                              setState(() {
                                isExpandedReference[index] = !isExpanded;
                              });
                            },
                            children: [
                              _buildServerSettings(),
                              _buildStorageSettings(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is SettingsInitial) {
                return Center(child: CircularProgressIndicator());
              }
              return Center(child: Text('Couldn\'t read state'));
            },
          ),
        ),
      ),
    );
  }
}
