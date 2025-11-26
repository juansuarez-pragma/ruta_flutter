import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failure.dart';

/// Clase base abstracta para casos de uso.
///
/// Define el contrato que todos los casos de uso deben implementar.
/// [T] es el tipo de retorno en caso de éxito.
/// [Params] es el tipo de parámetros que recibe el caso de uso.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
