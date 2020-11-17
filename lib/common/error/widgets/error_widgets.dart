import 'package:flutter/material.dart';

import '../../models/repository_response.dart';
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

class ErrorRepoResponseScreen extends StatelessWidget {
  const ErrorRepoResponseScreen({Key key, this.response}) : super(key: key);

  final RepositoryResponse response;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RawMaterialButton(
          constraints: const BoxConstraints.tightFor(width: 60, height: 60),
          onPressed: () => Navigator.pop(context),
          child: const Icon(Icons.clear),
        ),
        const Spacer(),
        CentredErrorText(error: response.error),
        const SizedBox(height: 16),
        for (var solution in response.solutions)
          _SolutionText(solution: solution),
        const Spacer(),
      ],
    );
  }
}

class _SolutionText extends StatelessWidget {
  const _SolutionText({Key key, this.solution}) : super(key: key);

  final String solution;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb),
            const SizedBox(width: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width - 100,
              child: Text(
                solution,
                style: Theme.of(context).textTheme.bodyText1,
                softWrap: true,
              ),
            ),
          ],
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
        CircleCloseButton(),
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
