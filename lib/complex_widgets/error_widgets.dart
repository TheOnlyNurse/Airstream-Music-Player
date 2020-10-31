import 'package:airstream/widgets/square_close_button.dart';

/// External Packages
import 'package:flutter/material.dart';

/// Internal Links
import '../models/repository_response.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({Key key, this.error}) : super(key: key);

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

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key key, this.response}) : super(key: key);

  final RepositoryResponse response;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RawMaterialButton(
          constraints: BoxConstraints.tightFor(width: 60, height: 60),
          child: Icon(Icons.clear),
          onPressed: () => Navigator.pop(context),
        ),
        Spacer(),
        ErrorText(error: response.error),
        SizedBox(height: 16),
        for (var solution in response.solutions)
          _SolutionText(solution: solution),
        Spacer(),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb),
            SizedBox(width: 15),
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

class NoStateErrorScreen extends StatelessWidget {
  const NoStateErrorScreen({Key key, @required this.state})
      : assert(state != null),
        super(key: key);

  final String state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SquareCloseButton(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Could not read state: $state. "
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
