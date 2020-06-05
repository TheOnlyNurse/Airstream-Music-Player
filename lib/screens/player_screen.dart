import 'package:flutter/material.dart';

class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'lib/graphics/microphone.png',
                  height: 256.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Slider(
                    value: 30,
                    min: 0,
                    max: 180,
                    divisions: 5,
                    onChanged: (data) => null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      iconSize: 48.0,
                      icon: Icon(Icons.arrow_back_ios),
                      onPressed: null,
                    ),
                    IconButton(
                      iconSize: 72.0,
                      icon: Icon(Icons.play_arrow),
                      onPressed: null,
                    ),
                    IconButton(
                      iconSize: 48.0,
                      icon: Icon(Icons.arrow_forward_ios),
                      onPressed: null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
