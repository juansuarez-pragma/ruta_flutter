import '../../value_objects/product/product_id.dart';
import '../../value_objects/shared/money.dart';
import '../domain_event.dart';

/// Evento emitido cuando se agrega un ítem al carrito.
class ItemAddedToCartEvent extends DomainEvent {
  /// ID del producto agregado.
  final ProductId productId;

  /// Cantidad agregada.
  final int quantity;

  /// Precio unitario al momento de agregar.
  final Money unitPrice;

  /// Crea un evento de ítem agregado al carrito.
  ItemAddedToCartEvent({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [super.props, productId, quantity, unitPrice];
}

/// Evento emitido cuando se actualiza la cantidad de un ítem.
class CartItemQuantityUpdatedEvent extends DomainEvent {
  /// ID del producto actualizado.
  final ProductId productId;

  /// Cantidad anterior.
  final int oldQuantity;

  /// Nueva cantidad.
  final int newQuantity;

  /// Crea un evento de cantidad actualizada.
  CartItemQuantityUpdatedEvent({
    required this.productId,
    required this.oldQuantity,
    required this.newQuantity,
  });

  @override
  List<Object?> get props => [super.props, productId, oldQuantity, newQuantity];
}

/// Evento emitido cuando se elimina un ítem del carrito.
class ItemRemovedFromCartEvent extends DomainEvent {
  /// ID del producto eliminado.
  final ProductId productId;

  /// Crea un evento de ítem eliminado del carrito.
  ItemRemovedFromCartEvent({required this.productId});

  @override
  List<Object?> get props => [super.props, productId];
}

/// Evento emitido cuando se vacía el carrito.
class CartClearedEvent extends DomainEvent {
  /// Cantidad de ítems que había antes de vaciar.
  final int itemsCleared;

  /// Total del carrito antes de vaciar.
  final Money totalCleared;

  /// Crea un evento de carrito vaciado.
  CartClearedEvent({required this.itemsCleared, required this.totalCleared});

  @override
  List<Object?> get props => [super.props, itemsCleared, totalCleared];
}
