import 'package:equatable/equatable.dart';

import '../../events/cart/cart_events.dart';
import '../../value_objects/cart/cart_item.dart';
import '../../value_objects/product/product_id.dart';
import '../../value_objects/shared/money.dart';

/// Resultado de una operación de carrito con su evento asociado.
class CartOperationResult<E> {
  /// El carrito actualizado.
  final CartAggregate cart;

  /// El evento generado por la operación.
  final E event;

  /// Crea un resultado de operación.
  const CartOperationResult({required this.cart, required this.event});
}

/// Excepción lanzada cuando ocurre un error en operaciones del carrito.
class CartException implements Exception {
  /// Mensaje descriptivo del error.
  final String message;

  /// Crea una excepción de carrito.
  const CartException(this.message);

  @override
  String toString() => 'CartException: $message';
}

/// Aggregate Root que representa un carrito de compras.
///
/// El carrito es el punto de entrada para todas las operaciones relacionadas
/// con la gestión de ítems de compra. Garantiza la consistencia de los datos
/// y genera eventos de dominio para cada operación significativa.
///
/// ## Invariantes
/// - Un producto solo puede aparecer una vez en el carrito
/// - La cantidad de cada ítem debe ser al menos 1
/// - El total nunca puede ser negativo
///
/// ## Inmutabilidad
/// Todas las operaciones retornan un nuevo carrito, manteniendo la
/// inmutabilidad del aggregate.
///
/// ## Ejemplo de uso
/// ```dart
/// var cart = CartAggregate.empty();
/// cart = cart.addItem(
///   productId: ProductId(1),
///   quantity: 2,
///   unitPrice: Money.fromDouble(50.0),
/// );
/// print(cart.total); // $100.00
/// ```
class CartAggregate extends Equatable {
  /// Lista inmutable de ítems en el carrito.
  final List<CartItem> _items;

  /// Crea un carrito con los ítems especificados.
  CartAggregate({required List<CartItem> items})
    : _items = List.unmodifiable(items);

  /// Crea un carrito vacío.
  factory CartAggregate.empty() => CartAggregate(items: const []);

  /// Retorna una copia inmutable de los ítems.
  List<CartItem> get items => List.unmodifiable(_items);

  /// Indica si el carrito está vacío.
  bool get isEmpty => _items.isEmpty;

  /// Indica si el carrito tiene ítems.
  bool get isNotEmpty => _items.isNotEmpty;

  /// Retorna el número total de unidades en el carrito.
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Retorna el número de productos diferentes en el carrito.
  int get uniqueItemCount => _items.length;

  /// Calcula el total del carrito.
  Money get total {
    if (_items.isEmpty) return Money.zero;
    return _items.fold(Money.zero, (sum, item) => sum.add(item.subtotal));
  }

  /// Agrega un ítem al carrito.
  ///
  /// Si el producto ya existe, incrementa la cantidad.
  /// Retorna un nuevo carrito con el ítem agregado.
  CartAggregate addItem({
    required ProductId productId,
    required int quantity,
    required Money unitPrice,
  }) {
    final existingIndex = _findItemIndex(productId);

    if (existingIndex >= 0) {
      // Producto existe, incrementar cantidad
      final existingItem = _items[existingIndex];
      final updatedItem = existingItem.incrementQuantity(quantity);
      final newItems = List<CartItem>.from(_items);
      newItems[existingIndex] = updatedItem;
      return CartAggregate(items: newItems);
    }

    // Producto nuevo, agregar
    final newItem = CartItem(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    return CartAggregate(items: [..._items, newItem]);
  }

  /// Agrega un ítem y retorna el carrito con el evento generado.
  CartOperationResult<ItemAddedToCartEvent> addItemWithEvent({
    required ProductId productId,
    required int quantity,
    required Money unitPrice,
  }) {
    final updatedCart = addItem(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    final event = ItemAddedToCartEvent(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
    );
    return CartOperationResult(cart: updatedCart, event: event);
  }

  /// Actualiza la cantidad de un ítem existente.
  ///
  /// Lanza [CartException] si el producto no existe.
  CartAggregate updateQuantity(ProductId productId, int newQuantity) {
    final index = _findItemIndex(productId);
    if (index < 0) {
      throw CartException(
        'Producto ${productId.value} no encontrado en el carrito',
      );
    }

    final updatedItem = _items[index].withQuantity(newQuantity);
    final newItems = List<CartItem>.from(_items);
    newItems[index] = updatedItem;
    return CartAggregate(items: newItems);
  }

  /// Actualiza la cantidad y retorna el carrito con el evento generado.
  CartOperationResult<CartItemQuantityUpdatedEvent> updateQuantityWithEvent(
    ProductId productId,
    int newQuantity,
  ) {
    final oldItem = getItem(productId);
    if (oldItem == null) {
      throw CartException(
        'Producto ${productId.value} no encontrado en el carrito',
      );
    }

    final updatedCart = updateQuantity(productId, newQuantity);
    final event = CartItemQuantityUpdatedEvent(
      productId: productId,
      oldQuantity: oldItem.quantity,
      newQuantity: newQuantity,
    );
    return CartOperationResult(cart: updatedCart, event: event);
  }

  /// Elimina un ítem del carrito.
  ///
  /// Lanza [CartException] si el producto no existe.
  CartAggregate removeItem(ProductId productId) {
    final index = _findItemIndex(productId);
    if (index < 0) {
      throw CartException(
        'Producto ${productId.value} no encontrado en el carrito',
      );
    }

    final newItems = List<CartItem>.from(_items)..removeAt(index);
    return CartAggregate(items: newItems);
  }

  /// Elimina un ítem y retorna el carrito con el evento generado.
  CartOperationResult<ItemRemovedFromCartEvent> removeItemWithEvent(
    ProductId productId,
  ) {
    final updatedCart = removeItem(productId);
    final event = ItemRemovedFromCartEvent(productId: productId);
    return CartOperationResult(cart: updatedCart, event: event);
  }

  /// Vacía el carrito completamente.
  CartAggregate clear() => CartAggregate.empty();

  /// Vacía el carrito y retorna el evento generado.
  CartOperationResult<CartClearedEvent> clearWithEvent() {
    final event = CartClearedEvent(
      itemsCleared: uniqueItemCount,
      totalCleared: total,
    );
    return CartOperationResult(cart: clear(), event: event);
  }

  /// Verifica si el carrito contiene un producto.
  bool containsProduct(ProductId productId) => _findItemIndex(productId) >= 0;

  /// Obtiene un ítem por ID de producto.
  ///
  /// Retorna null si no existe.
  CartItem? getItem(ProductId productId) {
    final index = _findItemIndex(productId);
    return index >= 0 ? _items[index] : null;
  }

  /// Busca el índice de un ítem por ID de producto.
  int _findItemIndex(ProductId productId) {
    return _items.indexWhere((item) => item.isSameProduct(productId));
  }

  @override
  List<Object?> get props => [_items];

  @override
  String toString() => 'CartAggregate(items: ${_items.length}, total: $total)';
}
