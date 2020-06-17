import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class AlphabeticalGridView extends StatelessWidget {
  const AlphabeticalGridView({
    @required this.headerStrings,
    @required this.builder,
    this.leading,
    this.controller,
  })  : assert(headerStrings != null),
        assert(builder != null);

  final List<String> headerStrings;
  final Widget Function(int startIndex, int endIndex) builder;
  final List<Widget> leading;
  final ScrollController controller;

  Map<String, Map<String, int>> _getHeaderIndexes() {
    final Map<String, Map<String, int>> headerIndexes = {};
    String currHeader;

    for (var index = 0; index < headerStrings.length; index++) {
      String _firstLetter = headerStrings[index][0].toUpperCase();

      if (currHeader != _firstLetter) {
        // Ensure headers can be updated to have an end index
        if (headerIndexes.containsKey(currHeader)) {
          headerIndexes[currHeader]['endIndex'] = index;
        }
        // Create new key for new header
        headerIndexes[_firstLetter] = {
          'startIndex': index,
          'endIndex': headerStrings.length,
        };
        currHeader = _firstLetter;
      }
    }

    return headerIndexes;
  }

  List<Widget> _createMultipleGrids(Map<String, Map<String, int>> headerIndexes) {
    List<Widget> sliverList = leading != null ? leading : [];
    // Build the grid with a header
    headerIndexes.forEach((letter, range) {
      sliverList.add(
        _CustomStickyHeader(
					title: letter,
					sliver: builder(range['startIndex'], range['endIndex']),
        ),
      );
    });
    return sliverList;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      controller: controller,
      slivers: _createMultipleGrids(_getHeaderIndexes()),
    );
  }
}

class _CustomStickyHeader extends StatelessWidget {
  final String title;
  final Widget sliver;

  _CustomStickyHeader({this.title, this.sliver});

  @override
  Widget build(BuildContext context) {
    return SliverStickyHeader(
      header: Container(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: Card(
                color: Theme.of(context).primaryColor,
                elevation: 9.0,
                child: Center(
                  child: Text(title, textScaleFactor: 2.0),
                ),
              ),
            ),
          ),
        ),
      ),
      sliver: sliver,
    );
  }
}
