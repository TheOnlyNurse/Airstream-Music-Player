import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

class SearchQuery extends SearchEvent {
  const SearchQuery(this.query);

  final String query;
}

class SearchFetch extends SearchEvent {}
