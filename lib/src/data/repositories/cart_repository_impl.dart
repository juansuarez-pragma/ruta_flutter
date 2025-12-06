import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/datasources/cart/cart_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/repositories/base/base_repository.dart';
import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/cart_repository.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

/// Implementación de [CartRepository].
///
/// Usa [CartRemoteDataSource] para obtener datos y [BaseRepository]
/// para manejar errores de forma consistente.
class CartRepositoryImpl extends BaseRepository implements CartRepository {
  final CartRemoteDataSource _cartDataSource;

  CartRepositoryImpl({required CartRemoteDataSource cartDataSource})
    : _cartDataSource = cartDataSource;

  @override
  Future<Either<Failure, List<CartEntity>>> getAllCarts() async {
    return await handleRequest(() async {
      final cartModels = await _cartDataSource.getAll();
      return cartModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, CartEntity>> getCartById(int id) async {
    return await handleRequest(() async {
      final cartModel = await _cartDataSource.getById(id);
      return cartModel.toEntity();
    }, notFoundMessage: AppStrings.notFoundCartFailureMessage);
  }

  @override
  Future<Either<Failure, List<CartEntity>>> getCartsByUser(int userId) async {
    return await handleRequest(() async {
      final cartModels = await _cartDataSource.getByUser(userId);
      return cartModels.map((model) => model.toEntity()).toList();
    });
  }
}
