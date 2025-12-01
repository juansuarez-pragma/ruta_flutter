import 'package:equatable/equatable.dart';

import '../product/product_id.dart';
import '../shared/money.dart';

/// Value Object que representa un ítem en el carrito de compras.
///
/// Encapsula la información de un producto en el carrito:
/// - El ID del producto
/// - La cantidad seleccionada
/// - El precio unitario al momento de agregarlo
///
/// ## Reglas de negocio
/// - La cantidad debe ser al menos 1
/// - El precio unitario debe ser no negativo (validado por [Money])
///
/// ## Inmutabilidad
/// Este objeto es inmutable. Para modificar la cantidad, usar los métodos
/// [withQuantity], [incrementQuantity] o [decrementQuantity] que retornan
/// nuevas instancias.
///
/// ## Ejemplo de uso
/// ```dart
/// final item = CartItem(
///   productId: ProductId(1),
///   quantity: 2,
///   unitPrice: Money.fromDouble(50.0),
/// );
/// print(item.subtotal); // Money(100.0)
/// final updated = item.incrementQuantity();
/// print(updated.quantity); // 3
/// ```
class CartItem extends Equatable {
  /// Identificador único del producto.
  final ProductId productId;

  /// Cantidad de unidades del producto en el carrito.
  final int quantity;

  /// Precio unitario del producto al momento de agregarlo al carrito.
  final Money unitPrice;

  /// Crea un ítem de carrito con los valores especificados.
  ///
  /// Lanza [ArgumentError] si [quantity] es menor a 1.
  CartItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  }) {
    if (quantity < 1) {
      throw ArgumentError('La cantidad debe ser al menos 1');
    }
  }

  /// Calcula el subtotal de este ítem (cantidad × precio unitario).
  Money get subtotal => unitPrice.multiply(quantity);

  /// Crea una copia del ítem con una nueva cantidad.
  ///
  /// Lanza [ArgumentError] si [newQuantity] es menor a 1.
  CartItem withQuantity(int newQuantity) {
    return CartItem(
      productId: productId,
      quantity: newQuantity,
      unitPrice: unitPrice,
    );
  }

  /// Incrementa la cantidad del ítem.
  ///
  /// Por defecto incrementa en 1. Se puede especificar un [amount] diferente.
  CartItem incrementQuantity([int amount = 1]) {
    return withQuantity(quantity + amount);
  }

  /// Decrementa la cantidad del ítem.
  ///
  /// Por defecto decrementa en 1. Se puede especificar un [amount] diferente.
  ///
  /// Lanza [ArgumentError] si el resultado sería menor a 1.
  CartItem decrementQuantity([int amount = 1]) {
    final newQuantity = quantity - amount;
    if (newQuantity < 1) {
      throw ArgumentError(
        'No se puede decrementar: la cantidad resultante ($newQuantity) sería menor a 1',
      );
    }
    return withQuantity(newQuantity);
  }

  /// Verifica si este ítem corresponde al producto especificado.
  bool isSameProduct(ProductId otherId) => productId == otherId;

  @override
  List<Object?> get props => [productId, quantity, unitPrice];

  @override
  String toString() =>
      'CartItem(productId: $productId, quantity: $quantity, unitPrice: $unitPrice)';
}
