import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/cart_repository.dart';

/// Caso de uso para obtener todos los carritos.
class GetAllCartsUseCase implements UseCase<List<CartEntity>, NoParams> {
  final CartRepository repository;

  GetAllCartsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CartEntity>>> call(NoParams params) async {
    return await repository.getAllCarts();
  }
}
