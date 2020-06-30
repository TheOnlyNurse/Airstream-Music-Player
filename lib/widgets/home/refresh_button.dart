import 'package:flutter/material.dart';

class RefreshButton extends StatefulWidget {
  final Future Function() onPressed;

  const RefreshButton({Key key, this.onPressed}) : super(key: key);

  @override
  _RefreshButtonState createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton> {
	bool _isRefreshing = false;

	bool get _isNotRefreshing => !_isRefreshing;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(top: 4),
			child: RawMaterialButton(
				child: Icon(_isNotRefreshing ? Icons.refresh : Icons.check),
				shape: CircleBorder(),
				constraints: BoxConstraints.tightFor(
					width: 50,
          height: 50,
        ),
				onPressed: () async {
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
