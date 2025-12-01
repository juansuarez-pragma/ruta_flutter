/// Tests para [ProductAggregate].
///
/// ESPECIFICACIÓN: ProductAggregate
///
/// Responsabilidad: Aggregate Root que encapsula la entidad Product
/// y sus comportamientos de dominio.
///
/// Propiedades (Value Objects):
///   - id: ProductId
///   - title: ProductTitle
///   - price: Money
///   - description: String
///   - category: String
///   - image: String
///   - rating: Rating (Value Object embebido)
///
/// Comportamientos:
///   - hasDiscount(Money originalPrice): bool - verifica si tiene descuento
///   - calculateDiscount(Money originalPrice): Money - calcula el descuento
///   - isInCategory(String category): bool - verifica si pertenece a categoría
///   - recordView(): ProductViewedEvent - registra visualización
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/aggregates/product/product_aggregate.dart';
import 'package:fase_2_consumo_api/src/domain/events/product/product_viewed_event.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_id.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_title.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/shared/money.dart';

void main() {
  // Helper para crear un aggregate de prueba
  ProductAggregate createTestAggregate({
    int id = 1,
    String title = 'Producto de prueba',
    double price = 99.99,
    String description = 'Descripción de prueba',
    String category = 'electronics',
    String image = 'https://example.com/image.jpg',
    double ratingRate = 4.5,
    int ratingCount = 100,
  }) {
    return ProductAggregate(
      id: ProductId(id),
      title: ProductTitle(title),
      price: Money.fromDouble(price),
      description: description,
      category: category,
      image: image,
      rating: Rating(rate: ratingRate, count: ratingCount),
    );
  }

  group('ProductAggregate', () {
    group('construcción', () {
      test('se crea correctamente con todos los parámetros', () {
        // Arrange & Act
        final product = createTestAggregate();

        // Assert
        expect(product.id, equals(ProductId(1)));
        expect(product.title, equals(ProductTitle('Producto de prueba')));
        expect(product.price, equals(Money.fromDouble(99.99)));
        expect(product.description, equals('Descripción de prueba'));
        expect(product.category, equals('electronics'));
        expect(product.image, equals('https://example.com/image.jpg'));
        expect(product.rating.rate, equals(4.5));
        expect(product.rating.count, equals(100));
      });

      test('dos productos con mismos valores son iguales (Equatable)', () {
        // Arrange
        final product1 = createTestAggregate();
        final product2 = createTestAggregate();

        // Assert
        expect(product1, equals(product2));
      });

      test('dos productos con diferentes valores son distintos', () {
        // Arrange
        final product1 = createTestAggregate(id: 1);
        final product2 = createTestAggregate(id: 2);

        // Assert
        expect(product1, isNot(equals(product2)));
      });
    });

    group('hasDiscount', () {
      test(
        'retorna true cuando precio actual es menor que precio original',
        () {
          // Arrange
          final product = createTestAggregate(price: 79.99);
          final originalPrice = Money.fromDouble(99.99);

          // Act
          final hasDiscount = product.hasDiscount(originalPrice);

          // Assert
          expect(hasDiscount, isTrue);
        },
      );

      test('retorna false cuando precio actual es igual al original', () {
        // Arrange
        final product = createTestAggregate(price: 99.99);
        final originalPrice = Money.fromDouble(99.99);

        // Act
        final hasDiscount = product.hasDiscount(originalPrice);

        // Assert
        expect(hasDiscount, isFalse);
      });

      test('retorna false cuando precio actual es mayor que original', () {
        // Arrange
        final product = createTestAggregate(price: 109.99);
        final originalPrice = Money.fromDouble(99.99);

        // Act
        final hasDiscount = product.hasDiscount(originalPrice);

        // Assert
        expect(hasDiscount, isFalse);
      });
    });

    group('calculateDiscount', () {
      test('calcula correctamente el monto del descuento', () {
        // Arrange
        final product = createTestAggregate(price: 79.99);
        final originalPrice = Money.fromDouble(99.99);

        // Act
        final discount = product.calculateDiscount(originalPrice);

        // Assert
        expect(discount, equals(Money.fromDouble(20.00)));
      });

      test('retorna zero cuando no hay descuento', () {
        // Arrange
        final product = createTestAggregate(price: 99.99);
        final originalPrice = Money.fromDouble(99.99);

        // Act
        final discount = product.calculateDiscount(originalPrice);

        // Assert
        expect(discount, equals(Money.zero));
      });

      test('retorna zero cuando precio actual es mayor que original', () {
        // Arrange
        final product = createTestAggregate(price: 109.99);
        final originalPrice = Money.fromDouble(99.99);

        // Act
        final discount = product.calculateDiscount(originalPrice);

        // Assert
        expect(discount, equals(Money.zero));
      });
    });

    group('isInCategory', () {
      test('retorna true cuando categoría coincide exactamente', () {
        // Arrange
        final product = createTestAggregate(category: 'electronics');

        // Act & Assert
        expect(product.isInCategory('electronics'), isTrue);
      });

      test('retorna false cuando categoría no coincide', () {
        // Arrange
        final product = createTestAggregate(category: 'electronics');

        // Act & Assert
        expect(product.isInCategory('clothing'), isFalse);
      });

      test('comparación es case-insensitive', () {
        // Arrange
        final product = createTestAggregate(category: 'Electronics');

        // Act & Assert
        expect(product.isInCategory('electronics'), isTrue);
        expect(product.isInCategory('ELECTRONICS'), isTrue);
      });
    });

    group('recordView', () {
      test('retorna un ProductViewedEvent con el productId correcto', () {
        // Arrange
        final product = createTestAggregate(id: 42);

        // Act
        final event = product.recordView();

        // Assert
        expect(event, isA<ProductViewedEvent>());
        expect(event.productId, equals(ProductId(42)));
      });

      test('cada llamada genera un evento con eventId único', () {
        // Arrange
        final product = createTestAggregate();

        // Act
        final event1 = product.recordView();
        final event2 = product.recordView();

        // Assert
        expect(event1.eventId, isNot(equals(event2.eventId)));
      });
    });

    group('discountPercentage', () {
      test('calcula correctamente el porcentaje de descuento', () {
        // Arrange
        final product = createTestAggregate(price: 80.00);
        final originalPrice = Money.fromDouble(100.00);

        // Act
        final percentage = product.discountPercentage(originalPrice);

        // Assert
        expect(percentage, equals(20.0));
      });

      test('retorna 0 cuando no hay descuento', () {
        // Arrange
        final product = createTestAggregate(price: 100.00);
        final originalPrice = Money.fromDouble(100.00);

        // Act
        final percentage = product.discountPercentage(originalPrice);

        // Assert
        expect(percentage, equals(0.0));
      });

      test('retorna 0 cuando precio actual es mayor', () {
        // Arrange
        final product = createTestAggregate(price: 120.00);
        final originalPrice = Money.fromDouble(100.00);

        // Act
        final percentage = product.discountPercentage(originalPrice);

        // Assert
        expect(percentage, equals(0.0));
      });
    });

    group('isHighlyRated', () {
      test('retorna true cuando rating >= 4.0', () {
        // Arrange
        final product = createTestAggregate(ratingRate: 4.0);

        // Act & Assert
        expect(product.isHighlyRated(), isTrue);
      });

      test('retorna true cuando rating > 4.0', () {
        // Arrange
        final product = createTestAggregate(ratingRate: 4.5);

        // Act & Assert
        expect(product.isHighlyRated(), isTrue);
      });

      test('retorna false cuando rating < 4.0', () {
        // Arrange
        final product = createTestAggregate(ratingRate: 3.9);

        // Act & Assert
        expect(product.isHighlyRated(), isFalse);
      });

      test('acepta threshold personalizado', () {
        // Arrange
        final product = createTestAggregate(ratingRate: 4.5);

        // Act & Assert
        expect(product.isHighlyRated(threshold: 4.5), isTrue);
        expect(product.isHighlyRated(threshold: 4.6), isFalse);
      });
    });

    group('hasEnoughReviews', () {
      test('retorna true cuando count >= minimumReviews', () {
        // Arrange
        final product = createTestAggregate(ratingCount: 100);

        // Act & Assert
        expect(product.hasEnoughReviews(minimumReviews: 50), isTrue);
      });

      test('retorna true cuando count == minimumReviews', () {
        // Arrange
        final product = createTestAggregate(ratingCount: 50);

        // Act & Assert
        expect(product.hasEnoughReviews(minimumReviews: 50), isTrue);
      });

      test('retorna false cuando count < minimumReviews', () {
        // Arrange
        final product = createTestAggregate(ratingCount: 49);

        // Act & Assert
        expect(product.hasEnoughReviews(minimumReviews: 50), isFalse);
      });

      test('usa valor por defecto de 10 reviews', () {
        // Arrange
        final productWithFew = createTestAggregate(ratingCount: 9);
        final productWithEnough = createTestAggregate(ratingCount: 10);

        // Act & Assert
        expect(productWithFew.hasEnoughReviews(), isFalse);
        expect(productWithEnough.hasEnoughReviews(), isTrue);
      });
    });
  });

  group('Rating', () {
    test('se crea correctamente con rate y count', () {
      // Arrange & Act
      final rating = Rating(rate: 4.5, count: 100);

      // Assert
      expect(rating.rate, equals(4.5));
      expect(rating.count, equals(100));
    });

    test('dos ratings con mismos valores son iguales', () {
      // Arrange
      final rating1 = Rating(rate: 4.5, count: 100);
      final rating2 = Rating(rate: 4.5, count: 100);

      // Assert
      expect(rating1, equals(rating2));
    });

    test('dos ratings con diferentes valores son distintos', () {
      // Arrange
      final rating1 = Rating(rate: 4.5, count: 100);
      final rating2 = Rating(rate: 4.0, count: 100);

      // Assert
      expect(rating1, isNot(equals(rating2)));
    });

    test('lanza error para rate negativo', () {
      expect(
        () => Rating(rate: -1.0, count: 100),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('lanza error para rate mayor a 5', () {
      expect(
        () => Rating(rate: 5.1, count: 100),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('lanza error para count negativo', () {
      expect(() => Rating(rate: 4.5, count: -1), throwsA(isA<ArgumentError>()));
    });

    test('acepta rate de 0', () {
      final rating = Rating(rate: 0.0, count: 0);
      expect(rating.rate, equals(0.0));
    });

    test('acepta rate de 5', () {
      final rating = Rating(rate: 5.0, count: 100);
      expect(rating.rate, equals(5.0));
    });

    test('toString retorna formato legible', () {
      // Arrange
      final rating = Rating(rate: 4.5, count: 100);

      // Act
      final str = rating.toString();

      // Assert
      expect(str, contains('4.5'));
      expect(str, contains('100'));
    });
  });
}
