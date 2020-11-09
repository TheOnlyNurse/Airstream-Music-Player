import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../common/repository/communication.dart';
import '../../../common/repository/image_repository.dart';
import '../../../common/repository/repository.dart';
import '../../../common/repository/song_repository.dart';
import '../../../common/static_assets.dart';
import '../../../common/widgets/custom_alert_dialog.dart';
import '../widgets/slider.dart';
import '../widgets/switch.dart';

class NetworkSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: WidgetProperties.scrollPhysics,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            const _Title(title: 'Offline Mode'),
            CustomSwitch(
              title: const Text('Go offline?'),
              leading: const Icon(Icons.cloud_off),
              initial: Repository().settings.isOffline,
              onChanged: (value) {
                Repository().settings.change(SettingType.isOffline, value);
              },
            ),
            CustomSwitch(
              title: const Text('Auto offline on mobile data'),
              leading: const Icon(Icons.signal_cellular_connected_no_internet_4_bar),
              initial: Repository().settings.autoOffline,
              onChanged: (value) {
                Repository().settings.change(SettingType.autoOffline, value);
              },
            ),
            const _Title(title: 'Cache'),
            const SettingsSlider(title: 'Prefetch', type: SettingType.prefetch),
            const SettingsSlider(
                title: 'Music Cache', type: SettingType.musicCache),
            const SettingsSlider(
                title: 'Image Cache', type: SettingType.imageCache),
            const SizedBox(height: 16),
            _ClearCache(
              imageRepository: GetIt.I.get<ImageRepository>(),
              songRepository: GetIt.I.get<SongRepository>(),
            ),
            const _Title(title: 'Bitrate'),
            const SettingsSlider(
              title: 'Wifi Bitrate',
              type: SettingType.wifiBitrate,
            ),
            const SettingsSlider(
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
  const _ClearCache(
      {Key key, @required this.imageRepository, @required this.songRepository})
      : assert(imageRepository != null),
        assert(songRepository != null),
        super(key: key);

  final ImageRepository imageRepository;
  final SongRepository songRepository;

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
                return const CustomAlertDialog(title: 'Clear cache?');
              });
          if (shouldClear) {
            songRepository.clearCache();
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
