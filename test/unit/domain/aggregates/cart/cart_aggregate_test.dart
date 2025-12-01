/// Tests unitarios para CartAggregate.
///
/// Verifica las reglas de negocio del carrito:
/// - Agregar ítems al carrito
/// - Actualizar cantidad de ítems
/// - Eliminar ítems del carrito
/// - Calcular total del carrito
/// - Vaciar el carrito
/// - Generación de eventos de dominio
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/aggregates/cart/cart_aggregate.dart';
import 'package:fase_2_consumo_api/src/domain/events/cart/cart_events.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/cart/cart_item.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_id.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/shared/money.dart';

void main() {
  group('CartAggregate', () {
    group('Creación', () {
      test('crea carrito vacío', () {
        // Act
        final cart = CartAggregate.empty();

        // Assert
        expect(cart.items, isEmpty);
        expect(cart.isEmpty, isTrue);
        expect(cart.itemCount, equals(0));
        expect(cart.total, equals(Money.zero));
      });

      test('crea carrito con ítems iniciales', () {
        // Arrange
        final items = [
          CartItem(
            productId: ProductId(1),
            quantity: 2,
            unitPrice: Money.fromDouble(50.0),
          ),
          CartItem(
            productId: ProductId(2),
            quantity: 1,
            unitPrice: Money.fromDouble(100.0),
          ),
        ];

        // Act
        final cart = CartAggregate(items: items);

        // Assert
        expect(cart.items.length, equals(2));
        expect(cart.isEmpty, isFalse);
      });
    });

    group('Agregar ítems', () {
      test('agrega nuevo ítem al carrito vacío', () {
        // Arrange
        final cart = CartAggregate.empty();

        // Act
        final updated = cart.addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(updated.items.length, equals(1));
        expect(updated.items.first.productId, equals(ProductId(1)));
        expect(updated.items.first.quantity, equals(2));
      });

      test('incrementa cantidad si producto ya existe en carrito', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = cart.addItem(
          productId: ProductId(1),
          quantity: 3,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(updated.items.length, equals(1));
        expect(updated.items.first.quantity, equals(5));
      });

      test('agrega múltiples productos diferentes', () {
        // Arrange
        var cart = CartAggregate.empty();

        // Act
        cart = cart.addItem(
          productId: ProductId(1),
          quantity: 1,
          unitPrice: Money.fromDouble(100.0),
        );
        cart = cart.addItem(
          productId: ProductId(2),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );
        cart = cart.addItem(
          productId: ProductId(3),
          quantity: 3,
          unitPrice: Money.fromDouble(25.0),
        );

        // Assert
        expect(cart.items.length, equals(3));
        expect(cart.itemCount, equals(6)); // 1 + 2 + 3
      });

      test('genera evento ItemAddedToCart al agregar ítem', () {
        // Arrange
        final cart = CartAggregate.empty();

        // Act
        final result = cart.addItemWithEvent(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(result.event, isA<ItemAddedToCartEvent>());
        expect(result.event.productId, equals(ProductId(1)));
        expect(result.event.quantity, equals(2));
      });
    });

    group('Actualizar cantidad', () {
      test('actualiza cantidad de ítem existente', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = cart.updateQuantity(ProductId(1), 5);

        // Assert
        expect(updated.items.first.quantity, equals(5));
      });

      test('lanza excepción si producto no existe al actualizar', () {
        // Arrange
        final cart = CartAggregate.empty();

        // Act & Assert
        expect(
          () => cart.updateQuantity(ProductId(999), 5),
          throwsA(isA<CartException>()),
        );
      });

      test('genera evento CartItemQuantityUpdated al actualizar', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final result = cart.updateQuantityWithEvent(ProductId(1), 5);

        // Assert
        expect(result.event, isA<CartItemQuantityUpdatedEvent>());
        expect(result.event.productId, equals(ProductId(1)));
        expect(result.event.oldQuantity, equals(2));
        expect(result.event.newQuantity, equals(5));
      });
    });

    group('Eliminar ítems', () {
      test('elimina ítem del carrito', () {
        // Arrange
        final cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(50.0),
            )
            .addItem(
              productId: ProductId(2),
              quantity: 1,
              unitPrice: Money.fromDouble(100.0),
            );

        // Act
        final updated = cart.removeItem(ProductId(1));

        // Assert
        expect(updated.items.length, equals(1));
        expect(updated.items.first.productId, equals(ProductId(2)));
      });

      test('lanza excepción si producto no existe al eliminar', () {
        // Arrange
        final cart = CartAggregate.empty();

        // Act & Assert
        expect(
          () => cart.removeItem(ProductId(999)),
          throwsA(isA<CartException>()),
        );
      });

      test('genera evento ItemRemovedFromCart al eliminar', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final result = cart.removeItemWithEvent(ProductId(1));

        // Assert
        expect(result.event, isA<ItemRemovedFromCartEvent>());
        expect(result.event.productId, equals(ProductId(1)));
      });
    });

    group('Cálculo de total', () {
      test('total es cero para carrito vacío', () {
        // Arrange
        final cart = CartAggregate.empty();

        // Assert
        expect(cart.total, equals(Money.zero));
      });

      test('calcula total correctamente con un ítem', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 3,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(cart.total, equals(Money.fromDouble(150.0)));
      });

      test('calcula total correctamente con múltiples ítems', () {
        // Arrange
        final cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(50.0), // 100
            )
            .addItem(
              productId: ProductId(2),
              quantity: 1,
              unitPrice: Money.fromDouble(75.0), // 75
            )
            .addItem(
              productId: ProductId(3),
              quantity: 3,
              unitPrice: Money.fromDouble(25.0), // 75
            );

        // Assert
        expect(cart.total, equals(Money.fromDouble(250.0)));
      });
    });

    group('Vaciar carrito', () {
      test('vacía todos los ítems del carrito', () {
        // Arrange
        final cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(50.0),
            )
            .addItem(
              productId: ProductId(2),
              quantity: 1,
              unitPrice: Money.fromDouble(100.0),
            );

        // Act
        final cleared = cart.clear();

        // Assert
        expect(cleared.isEmpty, isTrue);
        expect(cleared.items, isEmpty);
        expect(cleared.total, equals(Money.zero));
      });

      test('genera evento CartCleared al vaciar', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final result = cart.clearWithEvent();

        // Assert
        expect(result.event, isA<CartClearedEvent>());
      });
    });

    group('Consultas', () {
      test('containsProduct retorna true si producto existe', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(42),
          quantity: 1,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(cart.containsProduct(ProductId(42)), isTrue);
        expect(cart.containsProduct(ProductId(99)), isFalse);
      });

      test('getItem retorna ítem si existe', () {
        // Arrange
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(42),
          quantity: 3,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final item = cart.getItem(ProductId(42));

        // Assert
        expect(item, isNotNull);
        expect(item!.quantity, equals(3));
      });

      test('getItem retorna null si no existe', () {
        // Arrange
        final cart = CartAggregate.empty();

        // Act
        final item = cart.getItem(ProductId(42));

        // Assert
        expect(item, isNull);
      });

      test('itemCount retorna total de unidades', () {
        // Arrange
        final cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(50.0),
            )
            .addItem(
              productId: ProductId(2),
              quantity: 3,
              unitPrice: Money.fromDouble(50.0),
            );

        // Assert
        expect(cart.itemCount, equals(5)); // 2 + 3
        expect(cart.uniqueItemCount, equals(2)); // 2 productos diferentes
      });
    });

    group('Inmutabilidad', () {
      test('agregar ítem no modifica carrito original', () {
        // Arrange
        final original = CartAggregate.empty();

        // Act
        final updated = original.addItem(
          productId: ProductId(1),
          quantity: 1,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(original.isEmpty, isTrue);
        expect(updated.isEmpty, isFalse);
      });

      test('eliminar ítem no modifica carrito original', () {
        // Arrange
        final original = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 1,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = original.removeItem(ProductId(1));

        // Assert
        expect(original.items.length, equals(1));
        expect(updated.items.length, equals(0));
      });
    });
  });
}
