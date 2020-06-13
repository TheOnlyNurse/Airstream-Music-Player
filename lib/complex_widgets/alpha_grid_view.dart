import 'package:airstream/models/album_model.dart';
import 'package:airstream/models/artist_model.dart';
import 'package:airstream/widgets/sliver_card_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class AlphabeticalGridView extends StatelessWidget {
  final List<dynamic> modelList;
  final List<Widget> leading;
  final ScrollController controller;

  AlphabeticalGridView({@required this.modelList, this.leading, this.controller});

  Map<String, Map<String, int>> _getHeaderIndexes() {
    final list = this.modelList;
    final listLength = list.length;
    final Map<String, Map<String, int>> headerIndexes = {};
    String currHeader;

    for (var i = 0; i < listLength; i++) {
      String firstLetter;
      if (list[i] is Artist) {
        firstLetter = list[i].name[0].toUpperCase();
      }
      if (list[i] is Album) {
        firstLetter = list[i].title[0].toUpperCase();
      }
      if (firstLetter == null) {
        throw Exception('Couldn\'t read first letter. Check model type.');
      }
      if (currHeader != firstLetter) {
        // To ensure headers being update exist
        if (headerIndexes.containsKey(currHeader)) {
          headerIndexes[currHeader]['endIndex'] = i;
        }
        headerIndexes[firstLetter] = {'startIndex': i, 'endIndex': listLength};
        currHeader = firstLetter;
      }
    }

    return headerIndexes;
  }

  List<Widget> _createMultipleGrids(Map<String, Map<String, int>> headerIndexes) {
    final list = this.modelList;
    // The first widget should be the search bar widget
    List<Widget> sliverList = leading != null ? leading : [];
    // Build the grid with a header
    headerIndexes.forEach((letter, range) {
      final subList = list.sublist(range['startIndex'], range['endIndex']);
      sliverList.add(
        _CustomStickyHeader(
          title: letter,
          sliver: SliverCardGrid(modelList: subList),
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
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: Card(
                elevation: 9.0,
                shape: CircleBorder(),
                child: Center(
                  child: Text(
                    title,
                    textScaleFactor: 2.0,
                  ),
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
