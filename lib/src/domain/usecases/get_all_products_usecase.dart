import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';

/// Caso de uso para obtener todos los productos.
class GetAllProductsUseCase implements UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetAllProductsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(NoParams params) async {
    return await repository.getAllProducts();
  }
}
