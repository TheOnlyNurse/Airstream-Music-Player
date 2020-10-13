import 'package:flutter/material.dart';

const airstreamAlbumsDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 250,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  childAspectRatio: 1 / 1.25,
);

const airstreamArtistsDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 250,
  mainAxisSpacing: 20,
  crossAxisSpacing: 20,
  childAspectRatio: 1 / 1.2,
);

enum ErrorSolution { network, database, report, }

String errorSolution(ErrorSolution type) {
  switch(type){
    case ErrorSolution.network:
      return 'Network status could be offline. Check if this app has network access.';
      break;
    case ErrorSolution.database:
      return 'The local database could be out-of-date. Try refreshing it.';
      break;
    case ErrorSolution.report:
      return 'This isn\'t an unusual error. Please contact the developer.';
      break;
    default:
      throw UnimplementedError('No solution of type: $type');
  }
}