import 'package:equatable/equatable.dart';

/// Entidad que representa un producto dentro de un carrito.
///
/// Contiene la referencia al producto mediante [productId]
/// y la cantidad [quantity] de unidades en el carrito.
///
/// Es inmutable y usa [Equatable] para comparación por valor.
class CartProductEntity extends Equatable {
  final int productId;
  final int quantity;

  const CartProductEntity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}
