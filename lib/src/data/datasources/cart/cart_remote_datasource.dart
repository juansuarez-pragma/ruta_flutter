import 'package:fase_2_consumo_api/src/data/models/cart_model.dart';

/// Interface para el origen de datos remoto de carritos.
abstract class CartRemoteDataSource {
  /// Obtiene todos los carritos desde la API.
  Future<List<CartModel>> getAll();

  /// Obtiene un carrito por su ID.
  Future<CartModel> getById(int id);

  /// Obtiene los carritos de un usuario específico.
  Future<List<CartModel>> getByUser(int userId);
}
