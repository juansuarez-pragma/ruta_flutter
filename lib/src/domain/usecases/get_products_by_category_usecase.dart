import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';

/// Caso de uso para obtener productos filtrados por categoría.
///
/// Retorna [Either] con [Failure] en caso de error o lista de [ProductEntity]
/// que pertenecen a la categoría especificada.
class GetProductsByCategoryUseCase
    implements UseCase<List<ProductEntity>, CategoryParams> {
  final ProductRepository repository;

  GetProductsByCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(CategoryParams params) {
    return repository.getProductsByCategory(params.category);
  }
}

/// Parámetros para [GetProductsByCategoryUseCase].
///
/// Encapsula la categoría a filtrar. Usa [Equatable] para comparación por valor.
class CategoryParams extends Equatable {
  /// Nombre de la categoría a filtrar.
  final String category;

  const CategoryParams({required this.category});

  @override
  List<Object?> get props => [category];
}
