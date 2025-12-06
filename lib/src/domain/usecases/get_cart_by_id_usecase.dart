import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/cart_repository.dart';

/// Caso de uso para obtener un carrito por su ID.
class GetCartByIdUseCase implements UseCase<CartEntity, GetCartByIdParams> {
  final CartRepository repository;

  GetCartByIdUseCase(this.repository);

  @override
  Future<Either<Failure, CartEntity>> call(GetCartByIdParams params) async {
    return await repository.getCartById(params.id);
  }
}

/// Parámetros para el caso de uso [GetCartByIdUseCase].
class GetCartByIdParams extends Equatable {
  final int id;

  const GetCartByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
