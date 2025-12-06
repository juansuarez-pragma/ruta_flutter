import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/cart_repository.dart';

/// Caso de uso para obtener los carritos de un usuario.
class GetCartsByUserUseCase
    implements UseCase<List<CartEntity>, GetCartsByUserParams> {
  final CartRepository repository;

  GetCartsByUserUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartEntity>>> call(
    GetCartsByUserParams params,
  ) async {
    return await repository.getCartsByUser(params.userId);
  }
}

/// Parámetros para el caso de uso [GetCartsByUserUseCase].
class GetCartsByUserParams extends Equatable {
  final int userId;

  const GetCartsByUserParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
