import 'package:airstream/barrel/bloc_basics.dart';
import 'package:airstream/repository/image_repository.dart';
import 'package:airstream/widgets/custom_alert_dialog.dart';
import 'package:airstream/widgets/settings/custom_switch.dart';
import 'package:airstream/widgets/settings_slider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NetworkSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            _Title(title: 'Offline Mode'),
            CustomSwitch(
              title: Text('Go offline?'),
              leading: Icon(Icons.cloud_off),
              initial: Repository().settings.query(SettingType.isOffline),
              onChanged: (value) {
                Repository().settings.change(SettingType.isOffline, value);
              },
            ),
            CustomSwitch(
              title: Text('Auto offline on mobile data'),
              leading: Icon(Icons.signal_cellular_connected_no_internet_4_bar),
              initial: Repository().settings.query(SettingType.mobileOffline),
              onChanged: (value) {
                Repository().settings.change(SettingType.mobileOffline, value);
              },
            ),
            _Title(title: 'Cache'),
            SettingsSlider(title: 'Prefetch', type: SettingType.prefetch),
            SettingsSlider(title: 'Music Cache', type: SettingType.musicCache),
            SettingsSlider(title: 'Image Cache', type: SettingType.imageCache),
            SizedBox(height: 16),
            _ClearCache(imageRepository: GetIt.I.get<ImageRepository>()),
            _Title(title: 'Bitrate'),
            SettingsSlider(
              title: 'Wifi Bitrate',
              type: SettingType.wifiBitrate,
            ),
            SettingsSlider(
              title: 'Mobile Bitrate',
              type: SettingType.mobileBitrate,
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final String title;

  const _Title({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(title, style: Theme.of(context).textTheme.headline4),
      ),
    );
  }
}

class _ClearCache extends StatelessWidget {
  const _ClearCache({Key key, @required this.imageRepository})
      : assert(imageRepository != null),
        super(key: key);

  final ImageRepository imageRepository;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: RawMaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: Theme.of(context).errorColor,
        onPressed: () async {
          final shouldClear = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return CustomAlertDialog(title: 'Clear cache?');
              });
          if (shouldClear) {
            Repository().audioCache.deleteAll();
            imageRepository.clear();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Clear cache',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
      ),
    );
  }
}
