import 'package:flutter/material.dart';

/// Internal
import '../models/repository_response.dart';

class FutureButton<T> extends StatelessWidget {
  final Future<RepositoryResponse<T>> future;
  final Widget child;
  final void Function(T) onTap;

  const FutureButton({
    Key key,
    @required this.future,
    @required this.child,
    this.onTap,
  })  : assert(future != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepositoryResponse<T>>(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final response = snapshot.data;
          if (response.hasError) {
            throw Exception(
              'FutureButton received future with error: ${response.error}',
            );
          } else {
            return GestureDetector(
              onTap: () => onTap(response.data),
              child: child,
            );
          }
        }

        if (snapshot.hasError) {
          throw snapshot.error;
        }

        return child;
      },
    );
  }
}
