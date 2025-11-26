import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/util/strings.dart';

abstract class BaseRepository {
  @protected
  Future<Either<Failure, T>> handleRequest<T>(
    Future<T> Function() action, {
    String notFoundMessage = AppStrings.notFoundFailureMessage,
  }) async {
    try {
      final result = await action();
      return Right(result);
    } on ServerException {
      return Left(ServerFailure(AppStrings.serverFailureMessage));
    } on NotFoundException {
      return Left(NotFoundFailure(notFoundMessage));
    } on ClientException {
      return Left(ClientFailure(AppStrings.clientFailureMessage));
    } on ConnectionException {
      return Left(ConnectionFailure(AppStrings.connectionFailureMessage));
    } catch (e) {
      return Left(
        ServerFailure('${AppStrings.unexpectedFailureMessage} ${e.toString()}'),
      );
    }
  }
}
