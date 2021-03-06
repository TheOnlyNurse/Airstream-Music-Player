import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:math' as Math;

class AlphabeticalGridView extends StatelessWidget {
  const AlphabeticalGridView({
    @required this.headerStrings,
    @required this.builder,
    @required this.cacheKey,
    @required this.controller,
    this.leading,
  })  : assert(controller != null),
        assert(headerStrings != null),
        assert(cacheKey != null),
        assert(builder != null);

  final List<String> headerStrings;
  final Widget builder;
  final String cacheKey;
  final ScrollController controller;
  final List<Widget> leading;

  Future<Map<int, String>> _computeHeaders() async {
    final _hiveBox = Hive.box('cache');
    var cachedHeaders = _hiveBox.get(cacheKey);

    if (cachedHeaders == null) {
      cachedHeaders = await compute(getHeaders, headerStrings);
      _hiveBox.put(cacheKey, cachedHeaders);
    } else {
      cachedHeaders = Map<int, String>.from(cachedHeaders);
    }

    return cachedHeaders;
  }

  Widget _offsetToLabel(
      double offset, Map<int, String> headings, TextStyle style) {
    final card = 240;
    final current = Math.max(2, 2 + (offset ~/ card) * 2);
    final key = headings.keys.lastWhere((element) => current > element,
        orElse: () => headings.keys.last);
    return Text(headings[key], style: style);
  }

  Widget _customThumb(
      Color backgroundColor,
      Animation<double> thumbAnimation,
      Animation<double> labelAnimation,
      double height, {
        BoxConstraints labelConstraints,
        Text labelText,
      }) {
    return FadeTransition(
      opacity: thumbAnimation,
      child: SizedBox(
        height: height,
        width: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (labelText != null)
              Container(
                constraints: labelConstraints,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: labelText),
              ),
            if (labelText != null) SizedBox(width: 20),
            Container(
              height: height,
              width: 10,
              color: backgroundColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _computeHeaders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return DraggableScrollbar(
            labelTextBuilder: (offset) => _offsetToLabel(
              offset,
              snapshot.data,
              Theme.of(context).textTheme.headline6,
            ),
            controller: controller,
            backgroundColor: Theme.of(context).accentColor,
            heightScrollThumb: 50,
            labelConstraints: BoxConstraints.tightFor(width: 40),
            child: builder,
            scrollThumbBuilder: _customThumb,
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

Map<int, String> getHeaders(List<String> allTitles) {
  final headings = <int, String>{};
  String currentHeading;

  for (int index = 0; index < allTitles.length; index++) {
    final _firstLetter = allTitles[index][0].toUpperCase();

    if (currentHeading != _firstLetter) {
      currentHeading = _firstLetter;
      // Create new key for new header
      headings[index] = currentHeading;
    }
  }

  print(headings);
  return headings;
}
