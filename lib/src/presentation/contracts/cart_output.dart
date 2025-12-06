import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';

/// Contrato para mostrar datos de carritos.
abstract class CartOutput {
  /// Muestra una lista de carritos.
  void showCarts(List<CartEntity> carts);

  /// Muestra un carrito individual.
  void showCart(CartEntity cart);
}
