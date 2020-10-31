import 'package:flutter/material.dart';

class SquareCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: BoxConstraints.tightFor(width: 60, height: 60),
      onPressed: () => Navigator.pop(context),
      child: Icon(Icons.close),
    );
  }
}
