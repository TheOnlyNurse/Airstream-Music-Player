import 'package:airstream/models/repository_response.dart';
import 'package:flutter/material.dart';

class FutureButton<T> extends StatelessWidget {
  final Widget child;
  final Future<RepositoryResponse<T>> future;
  final void Function(T) onTap;

  const FutureButton({
    Key key,
    @required this.child,
    @required this.future,
    this.onTap,
  })  : assert(child != null),
        assert(future != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RepositoryResponse<T>>(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          var response = snapshot.data;
          if (response.hasError) {
            throw Exception(
              'Tappable received future with error: '
              '${response.error}',
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
