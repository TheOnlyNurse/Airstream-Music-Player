part of '../settings_foundation.dart';

class NetworkSettingsScreen extends StatelessWidget {
  const NetworkSettingsScreen({Key key, @required this.settings})
      : assert(settings != null),
        super(key: key);

  final SettingsRepository settings;

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
              initial: settings.isOffline,
              onChanged: (value) => settings.toggleOnline(),
            ),
            CustomSwitch(
              title: const Text('Auto offline on mobile data'),
              leading:
                  const Icon(Icons.signal_cellular_connected_no_internet_4_bar),
              initial: settings.autoOffline,
              onChanged: (value) => settings.toggleAutoOffline(),
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

// ignore: unused_element
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
