import 'package:flutter/material.dart';

class FutureButton<T> extends StatelessWidget {
  final Future<T> future;
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
    return FutureBuilder<T>(
      future: future,
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return child;
          case ConnectionState.done:
            return GestureDetector(
              onTap: () => onTap(snapshot.data),
              child: child,
            );
          default:
            return Stack(
              children: [
                Align(
                  alignment: const Alignment(1, 1),
                  child: Icon(
                    Icons.warning_amber_outlined,
                    color: Theme.of(context).errorColor,
                    size: 12,
                  ),
                ),
                child,
              ],
            );
        }
      },
    );
  }
}
