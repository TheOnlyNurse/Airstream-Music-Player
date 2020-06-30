import 'package:flutter/material.dart';

abstract class ProviderResponse {
  const ProviderResponse();

  bool get hasData;

  bool get hasNoData => !hasData;

  String get messageString;

  String get source;

  Widget get message {
    return SizedBox(
      height: 100,
      child: Column(
        children: <Widget>[
          Text(
						'Error!',
						style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
					),
					SizedBox(height: 8),
					Text('Source: ${source ?? 'Unknown'}'),
					Text('Issue: ${messageString ?? 'Unknown'}'),
				],
      ),
    );
  }

}
