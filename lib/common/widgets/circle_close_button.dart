import 'package:flutter/material.dart';

class CircleCloseButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: const BoxConstraints.tightFor(width: 55, height: 55),
      onPressed: () => Navigator.pop(context),
      shape: const CircleBorder(),
      child: const Icon(Icons.close),
    );
  }
}
