import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';

/// Caso de uso para obtener un producto por su ID.
class GetProductByIdUseCase
    implements UseCase<ProductEntity, GetProductByIdParams> {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(
    GetProductByIdParams params,
  ) async {
    return await repository.getProductById(params.id);
  }
}

/// Parámetros para el caso de uso [GetProductByIdUseCase].
class GetProductByIdParams extends Equatable {
  final int id;

  const GetProductByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
