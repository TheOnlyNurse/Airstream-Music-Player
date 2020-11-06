import 'package:flutter/material.dart';

class CircleCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tightFor(width: 55, height: 55),
      onPressed: () => Navigator.pop(context),
      shape: CircleBorder(),
      child: Icon(Icons.close),
    );
  }
}
