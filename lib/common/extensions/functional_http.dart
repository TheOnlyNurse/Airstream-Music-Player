import 'package:dartz/dartz.dart';
import 'package:http/http.dart';

extension FunctionalResponse<E> on Response {
  Either<String, Response> resolveStatus() {
    return statusCode == 200
        ? right(this)
        : left('Error: $statusCode. Reason: $body');
  }
}
