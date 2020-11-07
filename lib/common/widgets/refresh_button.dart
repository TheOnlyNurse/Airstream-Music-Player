import 'package:flutter/material.dart';

class RefreshButton extends StatefulWidget {
  final Future Function() onPressed;

  const RefreshButton({Key key, this.onPressed}) : super(key: key);

  @override
  _RefreshButtonState createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> {
  bool _isRefreshing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RawMaterialButton(
        child: _isRefreshing ? _RefreshingIndicator() : Icon(Icons.refresh),
        shape: CircleBorder(),
        constraints: BoxConstraints.tightFor(
          width: 50,
          height: 50,
        ),
        onPressed: () async {
          final _isNotRefreshing = !_isRefreshing;

          if (_isNotRefreshing) {
            // Show icon (and item associated) is now refresh
            setState(() {
              _isRefreshing = true;
            });
            // Run the widget
            await widget.onPressed();
            // Show icon in now able to be refreshed again
            setState(() {
              _isRefreshing = false;
            });
          } else {
            return null;
          }
        },
      ),
    );
  }
}

class _RefreshingIndicator extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).iconTheme.color,
        ),
        strokeWidth: 2.5,
      ),
    );
  }
}
