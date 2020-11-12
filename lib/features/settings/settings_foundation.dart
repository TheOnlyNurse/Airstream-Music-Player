import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../common/global_assets.dart';
import '../../common/repository/image_repository.dart';
import '../../common/repository/settings_repository.dart';
import '../../common/repository/song_repository.dart';
import '../../common/widgets/custom_alert_dialog.dart';

part 'screens/account_settings.dart';
part 'screens/network_settings.dart';
part 'screens/playback_settings.dart';
part 'screens/settings_title.dart';
part 'widgets/switch.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int currentPage = 0;
  PageController controller;

  @override
  void initState() {
    controller = PageController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: RawMaterialButton(
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.close),
        ),
        title: SettingsTitle(
          current: currentPage,
          onTap: (index) {
            setState(() {
              currentPage = index;
              controller.jumpToPage(index);
            });
          },
        ),
      ),
      body: SafeArea(
        child: PageView(
          physics: WidgetProperties.scrollPhysics,
          controller: controller,
          onPageChanged: (index) {
            setState(() {
              currentPage = index;
            });
          },
          children: <Widget>[
            NetworkSettingsScreen(
              settings: GetIt.I.get<SettingsRepository>(),
            ),
            AccountSettings(),
            PlaybackSettings(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
