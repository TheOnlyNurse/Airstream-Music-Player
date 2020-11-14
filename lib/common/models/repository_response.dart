
abstract class RepositoryResponse<T> {
  final String error;
  final List<String> solutions;
  final T data;

  const RepositoryResponse({this.data, this.error, this.solutions})
      : assert(!(error == null && data == null));

  bool get hasData => data != null;

  bool get hasError => !hasData;
}

class ListResponse<T> extends RepositoryResponse<List<T>> {
  const ListResponse({List<T> data, String error, List<String> solutions})
      : super(
          data: data,
          error: error,
          solutions: solutions,
        );
}

class SingleResponse<T> extends RepositoryResponse<T> {
  const SingleResponse({T data, String error, List<String> solutions})
      : super(
          data: data,
          error: error,
          solutions: solutions,
        );
}