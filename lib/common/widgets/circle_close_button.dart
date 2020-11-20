import 'package:flutter/material.dart';

class CircleCloseButton extends StatelessWidget {
  const CircleCloseButton({Key key, this.onPressed}) : super(key: key);

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      constraints: const BoxConstraints.tightFor(width: 55, height: 55),
      onPressed: onPressed ?? () => Navigator.pop(context),
      shape: const CircleBorder(),
      child: const Icon(Icons.close),
    );
  }
}
