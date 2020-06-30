import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String body;

  const CustomAlertDialog({Key key, this.title, this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonTextStyle = Theme.of(context).textTheme.subtitle1;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    );

    return AlertDialog(
      title: Text(title ?? 'Caution!'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 150,
        height: 70,
        child: Text(body ??
            'This action cannot be undone.\n'
                'Are you sure you want to proceed?'),
      ),
      actions: <Widget>[
        RawMaterialButton(
          shape: buttonShape,
          onPressed: () => Navigator.pop(context, false),
          child: Text('No', style: buttonTextStyle),
        ),
        RawMaterialButton(
          shape: buttonShape,
          onPressed: () => Navigator.pop(context, true),
          child: Text('Yes', style: buttonTextStyle),
        ),
      ],
    );
  }
}
