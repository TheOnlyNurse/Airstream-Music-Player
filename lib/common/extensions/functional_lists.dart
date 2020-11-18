import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';

extension FunctionalLists<E> on List<E> {
  Either<T, List<E>> removeEmpty<T>(T onEmpty) {
    return isEmpty ? left(onEmpty) : right(this);
  }

  Either<T, List<E>> onError<T>(
    bool Function(List<E> t) test, {
    @required T onError,
  }) {
    return test(this) ? right(this) : left(onError);
  }

  List<E> get returnShuffle {
    shuffle();
    return this;
  }

  List<E> get removeDuplicates {
    return LinkedHashSet<E>.from(this).toList();
  }

  /// Matches the order of the list with a new given one.
  ///
  /// [firstWhere] is the test used to match an [item] in the wanted list order
  /// with the [element] in the existing list.
  List<E> matchSort<T>(
    List<T> newOrder,
    bool Function(T item, E element) firstWhere,
  ) {
    return newOrder
        .map((item) => this.firstWhere((element) => firstWhere(item, element)))
        .toList();
  }
}
