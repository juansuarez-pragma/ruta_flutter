/// Tests de Aceptación: Carrito de Compras
///
/// FEATURE: Gestión del carrito de compras
///   Como usuario de la aplicación
///   Quiero gestionar mi carrito de compras
///   Para poder comprar los productos que deseo
///
/// CRITERIOS DE ACEPTACIÓN:
///   - AC1: El usuario puede agregar productos al carrito
///   - AC2: El usuario puede ver el contenido del carrito
///   - AC3: El usuario puede actualizar la cantidad de un producto
///   - AC4: El usuario puede eliminar productos del carrito
///   - AC5: El sistema calcula el total correctamente
///   - AC6: El usuario puede vaciar el carrito
///   - AC7: El sistema registra eventos de las operaciones
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/aggregates/cart/cart_aggregate.dart';
import 'package:fase_2_consumo_api/src/domain/events/cart/cart_events.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/cart/cart_item.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_id.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/shared/money.dart';

void main() {
  group('Feature: Gestión del carrito de compras', () {
    group('Scenario: AC1 - Usuario agrega productos al carrito', () {
      test('Given carrito vacío, '
          'When agrega producto con cantidad 2, '
          'Then carrito contiene el producto', () {
        // Given
        var cart = CartAggregate.empty();
        expect(cart.isEmpty, isTrue);

        // When
        cart = cart.addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Then
        expect(cart.isEmpty, isFalse);
        expect(cart.containsProduct(ProductId(1)), isTrue);
        expect(cart.itemCount, equals(2));
      });

      test('Given carrito con producto, '
          'When agrega mismo producto, '
          'Then incrementa cantidad existente', () {
        // Given
        var cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // When
        cart = cart.addItem(
          productId: ProductId(1),
          quantity: 3,
          unitPrice: Money.fromDouble(50.0),
        );

        // Then
        expect(cart.uniqueItemCount, equals(1));
        expect(cart.itemCount, equals(5)); // 2 + 3
      });
    });

    group('Scenario: AC2 - Usuario ve contenido del carrito', () {
      test('Given carrito con múltiples productos, '
          'When consulta contenido, '
          'Then ve todos los productos con sus detalles', () {
        // Given
        final cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(100.0),
            )
            .addItem(
              productId: ProductId(2),
              quantity: 1,
              unitPrice: Money.fromDouble(50.0),
            );

        // When
        final items = cart.items;

        // Then
        expect(items.length, equals(2));

        final item1 = cart.getItem(ProductId(1));
        expect(item1, isNotNull);
        expect(item1!.quantity, equals(2));
        expect(item1.unitPrice, equals(Money.fromDouble(100.0)));

        final item2 = cart.getItem(ProductId(2));
        expect(item2, isNotNull);
        expect(item2!.quantity, equals(1));
      });
    });

    group('Scenario: AC3 - Usuario actualiza cantidad de producto', () {
      test('Given producto en carrito con cantidad 2, '
          'When actualiza a cantidad 5, '
          'Then el producto tiene nueva cantidad', () {
        // Given
        var cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );
        expect(cart.getItem(ProductId(1))!.quantity, equals(2));

        // When
        cart = cart.updateQuantity(ProductId(1), 5);

        // Then
        expect(cart.getItem(ProductId(1))!.quantity, equals(5));
      });

      test('Given carrito vacío, '
          'When intenta actualizar producto inexistente, '
          'Then recibe error descriptivo', () {
        // Given
        final cart = CartAggregate.empty();

        // When & Then
        expect(
          () => cart.updateQuantity(ProductId(999), 5),
          throwsA(
            isA<CartException>().having(
              (e) => e.message,
              'message',
              contains('no encontrado'),
            ),
          ),
        );
      });
    });

    group('Scenario: AC4 - Usuario elimina productos del carrito', () {
      test('Given carrito con 2 productos, '
          'When elimina uno, '
          'Then carrito tiene solo el otro', () {
        // Given
        var cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 1,
              unitPrice: Money.fromDouble(100.0),
            )
            .addItem(
              productId: ProductId(2),
              quantity: 1,
              unitPrice: Money.fromDouble(50.0),
            );

        // When
        cart = cart.removeItem(ProductId(1));

        // Then
        expect(cart.uniqueItemCount, equals(1));
        expect(cart.containsProduct(ProductId(1)), isFalse);
        expect(cart.containsProduct(ProductId(2)), isTrue);
      });

      test('Given carrito vacío, '
          'When intenta eliminar producto, '
          'Then recibe error', () {
        // Given
        final cart = CartAggregate.empty();

        // When & Then
        expect(
          () => cart.removeItem(ProductId(1)),
          throwsA(isA<CartException>()),
        );
      });
    });

    group('Scenario: AC5 - Sistema calcula total correctamente', () {
      test('Given carrito vacío, '
          'When consulta total, '
          'Then total es cero', () {
        // Given
        final cart = CartAggregate.empty();

        // Then
        expect(cart.total, equals(Money.zero));
      });

      test('Given carrito con productos variados, '
          'When consulta total, '
          'Then calcula suma de subtotales', () {
        // Given
        final cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(100.0), // 200
            )
            .addItem(
              productId: ProductId(2),
              quantity: 3,
              unitPrice: Money.fromDouble(50.0), // 150
            )
            .addItem(
              productId: ProductId(3),
              quantity: 1,
              unitPrice: Money.fromDouble(75.0), // 75
            );

        // Then
        expect(cart.total, equals(Money.fromDouble(425.0)));
      });

      test('Given carrito con productos, '
          'When elimina uno, '
          'Then total se recalcula', () {
        // Given
        var cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(100.0), // 200
            )
            .addItem(
              productId: ProductId(2),
              quantity: 1,
              unitPrice: Money.fromDouble(50.0), // 50
            );
        expect(cart.total, equals(Money.fromDouble(250.0)));

        // When
        cart = cart.removeItem(ProductId(2));

        // Then
        expect(cart.total, equals(Money.fromDouble(200.0)));
      });
    });

    group('Scenario: AC6 - Usuario vacía el carrito', () {
      test('Given carrito con productos, '
          'When vacía el carrito, '
          'Then carrito queda sin productos', () {
        // Given
        var cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 5,
              unitPrice: Money.fromDouble(100.0),
            )
            .addItem(
              productId: ProductId(2),
              quantity: 3,
              unitPrice: Money.fromDouble(50.0),
            );
        expect(cart.isNotEmpty, isTrue);

        // When
        cart = cart.clear();

        // Then
        expect(cart.isEmpty, isTrue);
        expect(cart.total, equals(Money.zero));
        expect(cart.itemCount, equals(0));
      });
    });

    group('Scenario: AC7 - Sistema registra eventos de operaciones', () {
      test('Given carrito vacío, '
          'When agrega producto con evento, '
          'Then genera ItemAddedToCartEvent', () {
        // Given
        final cart = CartAggregate.empty();

        // When
        final result = cart.addItemWithEvent(
          productId: ProductId(42),
          quantity: 3,
          unitPrice: Money.fromDouble(99.99),
        );

        // Then
        expect(result.event, isA<ItemAddedToCartEvent>());
        expect(result.event.productId, equals(ProductId(42)));
        expect(result.event.quantity, equals(3));
        expect(result.event.unitPrice, equals(Money.fromDouble(99.99)));
        expect(result.cart.containsProduct(ProductId(42)), isTrue);
      });

      test('Given producto en carrito, '
          'When actualiza cantidad con evento, '
          'Then genera CartItemQuantityUpdatedEvent', () {
        // Given
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // When
        final result = cart.updateQuantityWithEvent(ProductId(1), 10);

        // Then
        expect(result.event, isA<CartItemQuantityUpdatedEvent>());
        expect(result.event.productId, equals(ProductId(1)));
        expect(result.event.oldQuantity, equals(2));
        expect(result.event.newQuantity, equals(10));
      });

      test('Given producto en carrito, '
          'When elimina con evento, '
          'Then genera ItemRemovedFromCartEvent', () {
        // Given
        final cart = CartAggregate.empty().addItem(
          productId: ProductId(1),
          quantity: 1,
          unitPrice: Money.fromDouble(50.0),
        );

        // When
        final result = cart.removeItemWithEvent(ProductId(1));

        // Then
        expect(result.event, isA<ItemRemovedFromCartEvent>());
        expect(result.event.productId, equals(ProductId(1)));
        expect(result.cart.isEmpty, isTrue);
      });

      test('Given carrito con productos, '
          'When vacía con evento, '
          'Then genera CartClearedEvent con info del estado anterior', () {
        // Given
        final cart = CartAggregate.empty()
            .addItem(
              productId: ProductId(1),
              quantity: 2,
              unitPrice: Money.fromDouble(100.0),
            )
            .addItem(
              productId: ProductId(2),
              quantity: 1,
              unitPrice: Money.fromDouble(50.0),
            );

        // When
        final result = cart.clearWithEvent();

        // Then
        expect(result.event, isA<CartClearedEvent>());
        expect(result.event.itemsCleared, equals(2));
        expect(result.event.totalCleared, equals(Money.fromDouble(250.0)));
        expect(result.cart.isEmpty, isTrue);
      });
    });

    group('Scenario: AC8 - CartItem calcula subtotal correctamente', () {
      test('Given ítem con cantidad y precio, '
          'When consulta subtotal, '
          'Then es cantidad × precio', () {
        // Given
        final item = CartItem(
          productId: ProductId(1),
          quantity: 4,
          unitPrice: Money.fromDouble(25.0),
        );

        // Then
        expect(item.subtotal, equals(Money.fromDouble(100.0)));
      });

      test('Given ítem, '
          'When incrementa cantidad, '
          'Then subtotal aumenta proporcionalmente', () {
        // Given
        var item = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );
        expect(item.subtotal, equals(Money.fromDouble(100.0)));

        // When
        item = item.incrementQuantity(3);

        // Then
        expect(item.quantity, equals(5));
        expect(item.subtotal, equals(Money.fromDouble(250.0)));
      });
    });
  });
}
