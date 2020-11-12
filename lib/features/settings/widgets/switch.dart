part of '../settings_foundation.dart';

class CustomSwitch extends StatefulWidget {
  final bool initial;
  final Widget title;
  final Widget leading;
  final Function(bool) onChanged;

  const CustomSwitch({
    Key key,
    @required this.initial,
    this.title,
    this.leading,
    this.onChanged,
  })  : assert(initial != null),
        super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  bool value;

  @override
  void initState() {
    value = widget.initial;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: widget.leading,
      title: widget.title,
      value: value,
      activeColor: Theme.of(context).accentColor,
      onChanged: (newValue) {
        setState(() {
          value = newValue;
          if (widget.onChanged != null) widget.onChanged(value);
        });
      },
    );
  }
}
