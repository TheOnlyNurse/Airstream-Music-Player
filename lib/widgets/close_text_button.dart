import 'package:flutter/material.dart';

class CloseTextButton extends StatelessWidget {
  Widget _closeText(BuildContext context, {Color color, Paint foreground}) {
    return Text(
      'Back',
      style: Theme.of(context).textTheme.headline6.copyWith(
            foreground: foreground,
            color: color,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () => Navigator.pop(context),
      child: Stack(
        children: <Widget>[
          _closeText(
            context,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Theme.of(context).primaryColor,
          ),
          _closeText(context, color: Colors.white),
        ],
      ),
    );
  }
}
