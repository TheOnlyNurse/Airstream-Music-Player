import 'package:flutter/material.dart';
import 'widgets/error_widgets.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key key, this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: RawMaterialButton(
            constraints: const BoxConstraints.tightFor(width: 60, height: 60),
            onPressed: () => Navigator.pop(context),
            shape: const CircleBorder(),
            child: const Icon(Icons.clear),
          ),
        ),
        Expanded(child: CentredErrorText(error: message)),
      ],
    );
  }
}
