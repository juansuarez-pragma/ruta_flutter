/// Tests unitarios para CartItem Value Object.
///
/// Verifica las reglas de negocio:
/// - La cantidad debe ser positiva (≥1)
/// - El precio unitario debe ser no negativo
/// - El subtotal se calcula correctamente
/// - Es inmutable y comparable por valor
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/value_objects/cart/cart_item.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_id.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/shared/money.dart';

void main() {
  group('CartItem', () {
    group('Creación', () {
      test('crea CartItem con valores válidos', () {
        // Arrange & Act
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(cartItem.productId, equals(ProductId(1)));
        expect(cartItem.quantity, equals(2));
        expect(cartItem.unitPrice, equals(Money.fromDouble(50.0)));
      });

      test('crea CartItem con cantidad mínima (1)', () {
        // Arrange & Act
        final cartItem = CartItem(
          productId: ProductId(5),
          quantity: 1,
          unitPrice: Money.fromDouble(25.0),
        );

        // Assert
        expect(cartItem.quantity, equals(1));
      });

      test('crea CartItem con precio cero', () {
        // Arrange & Act
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 1,
          unitPrice: Money.zero,
        );

        // Assert
        expect(cartItem.unitPrice, equals(Money.zero));
      });
    });

    group('Validaciones', () {
      test('rechaza cantidad cero', () {
        expect(
          () => CartItem(
            productId: ProductId(1),
            quantity: 0,
            unitPrice: Money.fromDouble(10.0),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('rechaza cantidad negativa', () {
        expect(
          () => CartItem(
            productId: ProductId(1),
            quantity: -1,
            unitPrice: Money.fromDouble(10.0),
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Cálculo de subtotal', () {
      test('calcula subtotal correctamente para cantidad 1', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 1,
          unitPrice: Money.fromDouble(99.99),
        );

        // Act
        final subtotal = cartItem.subtotal;

        // Assert
        expect(subtotal, equals(Money.fromDouble(99.99)));
      });

      test('calcula subtotal correctamente para cantidad mayor a 1', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 3,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final subtotal = cartItem.subtotal;

        // Assert
        expect(subtotal, equals(Money.fromDouble(150.0)));
      });

      test('subtotal es cero cuando precio unitario es cero', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 10,
          unitPrice: Money.zero,
        );

        // Act
        final subtotal = cartItem.subtotal;

        // Assert
        expect(subtotal, equals(Money.zero));
      });
    });

    group('Actualización de cantidad', () {
      test('withQuantity crea nuevo CartItem con nueva cantidad', () {
        // Arrange
        final original = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = original.withQuantity(5);

        // Assert
        expect(updated.quantity, equals(5));
        expect(updated.productId, equals(original.productId));
        expect(updated.unitPrice, equals(original.unitPrice));
        expect(original.quantity, equals(2)); // Original no modificado
      });

      test('withQuantity rechaza cantidad inválida', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act & Assert
        expect(() => cartItem.withQuantity(0), throwsA(isA<ArgumentError>()));
        expect(() => cartItem.withQuantity(-1), throwsA(isA<ArgumentError>()));
      });
    });

    group('Incremento/Decremento de cantidad', () {
      test('incrementQuantity aumenta cantidad en 1 por defecto', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = cartItem.incrementQuantity();

        // Assert
        expect(updated.quantity, equals(3));
      });

      test('incrementQuantity aumenta cantidad en valor especificado', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = cartItem.incrementQuantity(5);

        // Assert
        expect(updated.quantity, equals(7));
      });

      test('decrementQuantity disminuye cantidad en 1 por defecto', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 5,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = cartItem.decrementQuantity();

        // Assert
        expect(updated.quantity, equals(4));
      });

      test('decrementQuantity disminuye cantidad en valor especificado', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 10,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act
        final updated = cartItem.decrementQuantity(3);

        // Assert
        expect(updated.quantity, equals(7));
      });

      test('decrementQuantity no permite cantidad menor a 1', () {
        // Arrange
        final cartItem = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Act & Assert
        expect(
          () => cartItem.decrementQuantity(2),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => cartItem.decrementQuantity(5),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Igualdad (Equatable)', () {
      test('dos CartItem con mismos valores son iguales', () {
        // Arrange
        final item1 = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );
        final item2 = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(item1, equals(item2));
        expect(item1.hashCode, equals(item2.hashCode));
      });

      test('dos CartItem con diferente productId son diferentes', () {
        // Arrange
        final item1 = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );
        final item2 = CartItem(
          productId: ProductId(2),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(item1, isNot(equals(item2)));
      });

      test('dos CartItem con diferente cantidad son diferentes', () {
        // Arrange
        final item1 = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );
        final item2 = CartItem(
          productId: ProductId(1),
          quantity: 3,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(item1, isNot(equals(item2)));
      });

      test('dos CartItem con diferente precio son diferentes', () {
        // Arrange
        final item1 = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(50.0),
        );
        final item2 = CartItem(
          productId: ProductId(1),
          quantity: 2,
          unitPrice: Money.fromDouble(60.0),
        );

        // Assert
        expect(item1, isNot(equals(item2)));
      });
    });

    group('Métodos utilitarios', () {
      test('isSameProduct identifica mismo producto', () {
        // Arrange
        final item = CartItem(
          productId: ProductId(42),
          quantity: 1,
          unitPrice: Money.fromDouble(50.0),
        );

        // Assert
        expect(item.isSameProduct(ProductId(42)), isTrue);
        expect(item.isSameProduct(ProductId(43)), isFalse);
      });

      test('toString retorna representación legible', () {
        // Arrange
        final item = CartItem(
          productId: ProductId(1),
          quantity: 3,
          unitPrice: Money.fromDouble(25.5),
        );

        // Act
        final str = item.toString();

        // Assert
        expect(str, contains('CartItem'));
        expect(str, contains('productId'));
        expect(str, contains('quantity'));
      });
    });
  });
}
