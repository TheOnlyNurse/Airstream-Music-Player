part of '../settings_foundation.dart';

class SettingsTitle extends StatefulWidget {
  final int current;
  final Function(int) onTap;

  const SettingsTitle({Key key, this.current = 0, this.onTap})
      : super(key: key);

  @override
  _SettingsTitleState createState() => _SettingsTitleState();
}

class _SettingsTitleState extends State<SettingsTitle> {
  ScrollController controller;
  int shownIndex = 0;

  @override
  void initState() {
    controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.headline4;
    final disabled = baseStyle.copyWith(color: theme.disabledColor);
    final selected = baseStyle.copyWith(color: theme.accentColor);

    final titles = <String>['Network', 'Account', 'Playback'];

    if (shownIndex != widget.current) {
      controller.animateTo(
        widget.current.toDouble() * 38,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
      shownIndex = widget.current;
    }

    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        physics: WidgetProperties.scrollPhysics,
        itemBuilder: (context, index) {
          return Center(
            child: AnimatedDefaultTextStyle(
              style: index == widget.current ? selected : disabled,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
              child: GestureDetector(
                onTap: widget.onTap != null ? () => widget.onTap(index) : null,
                child: Text(titles[index]),
              ),
            ),
          );
        },
        itemCount: titles.length,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
