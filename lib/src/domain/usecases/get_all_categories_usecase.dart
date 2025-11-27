import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';

/// Caso de uso para obtener todas las categorías.
class GetAllCategoriesUseCase implements UseCase<List<String>, NoParams> {
  final ProductRepository repository;

  GetAllCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) async {
    return await repository.getAllCategories();
  }
}
