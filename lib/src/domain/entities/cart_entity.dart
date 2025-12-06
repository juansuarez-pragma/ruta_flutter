import 'package:equatable/equatable.dart';
import 'cart_product_entity.dart';

/// Entidad que representa un carrito de compras.
///
/// Contiene el identificador [id], el usuario propietario [userId],
/// la fecha de creación [date] y la lista de productos [products].
///
/// Es inmutable y usa [Equatable] para comparación por valor.
class CartEntity extends Equatable {
  final int id;
  final int userId;
  final DateTime date;
  final List<CartProductEntity> products;

  const CartEntity({
    required this.id,
    required this.userId,
    required this.date,
    required this.products,
  });

  @override
  List<Object?> get props => [id, userId, date, products];
}
