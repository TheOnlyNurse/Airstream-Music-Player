import 'package:flutter/material.dart';

import '../../widgets/circle_close_button.dart';

class CentredErrorText extends StatelessWidget {
  const CentredErrorText({Key key, this.error}) : super(key: key);

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          error,
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class StateErrorScreen extends StatelessWidget {
  const StateErrorScreen({Key key, @required this.message})
      : assert(message != null),
        super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleCloseButton(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Could not read state: $message. "
                "This shouldn't have happened, "
                "please report this to the developer.",
                style: Theme.of(context).textTheme.headline6,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
