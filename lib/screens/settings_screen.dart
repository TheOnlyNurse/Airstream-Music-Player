import 'package:airstream/screens/settings/account_settings.dart';
import 'package:airstream/screens/settings/network_settings.dart';
import 'package:airstream/screens/settings/playback_settings.dart';
import 'package:airstream/screens/settings/settings_title.dart';
import 'package:flutter/material.dart';

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
          child: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
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
					physics: BouncingScrollPhysics(),
					controller: controller,
					onPageChanged: (index) {
						setState(() {
							currentPage = index;
						});
					},
					children: <Widget>[
						NetworkSettingsScreen(),
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
