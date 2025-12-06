import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';

/// Interfaz del repositorio de carritos.
///
/// Define el contrato para acceder a los datos de carritos.
/// La implementación concreta está en la capa de datos.
abstract class CartRepository {
  /// Obtiene todos los carritos.
  ///
  /// Retorna [Either] con:
  /// - [Failure] en caso de error
  /// - [List<CartEntity>] con la lista de carritos
  Future<Either<Failure, List<CartEntity>>> getAllCarts();

  /// Obtiene un carrito por su ID.
  ///
  /// [id] es el identificador único del carrito.
  ///
  /// Retorna [Either] con:
  /// - [Failure] en caso de error
  /// - [CartEntity] con el carrito encontrado
  Future<Either<Failure, CartEntity>> getCartById(int id);

  /// Obtiene los carritos de un usuario específico.
  ///
  /// [userId] es el identificador del usuario.
  ///
  /// Retorna [Either] con:
  /// - [Failure] en caso de error
  /// - [List<CartEntity>] con los carritos del usuario
  Future<Either<Failure, List<CartEntity>>> getCartsByUser(int userId);
}
