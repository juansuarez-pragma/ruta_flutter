/// Tests de Aceptación: Comportamientos del Producto (DDD)
///
/// FEATURE: Comportamientos de dominio del producto
///   Como sistema de e-commerce
///   Quiero que los productos tengan comportamientos de negocio
///   Para aplicar reglas de descuento, destacados y métricas
///
/// CRITERIOS DE ACEPTACIÓN:
///   - AC1: El sistema puede calcular descuentos de productos
///   - AC2: El sistema puede identificar productos destacados
///   - AC3: El sistema puede filtrar por categoría
///   - AC4: El sistema registra visualizaciones de productos
///   - AC5: Los Value Objects validan datos correctamente
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/aggregates/product/product_aggregate.dart';
import 'package:fase_2_consumo_api/src/domain/events/product/product_viewed_event.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_id.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_title.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/shared/money.dart';

/// Helper para crear ProductAggregate de prueba.
ProductAggregate createTestProductAggregate({
  int id = 1,
  String title = 'Producto Test',
  double price = 100.0,
  String category = 'electronics',
  double ratingRate = 4.5,
  int ratingCount = 100,
}) {
  return ProductAggregate(
    id: ProductId(id),
    title: ProductTitle(title),
    price: Money.fromDouble(price),
    description: 'Descripción de prueba',
    category: category,
    image: 'https://example.com/image.jpg',
    rating: Rating(rate: ratingRate, count: ratingCount),
  );
}

void main() {
  group('Feature: Comportamientos de dominio del producto', () {
    group('Scenario: AC1 - Calcular descuento de un producto', () {
      test('Given producto con precio \$80 y original \$100, '
          'When calcula descuento, '
          'Then descuento es \$20 (20%)', () {
        // Given
        final product = createTestProductAggregate(price: 80.0);
        final originalPrice = Money.fromDouble(100.0);

        // When
        final discount = product.calculateDiscount(originalPrice);
        final percentage = product.discountPercentage(originalPrice);

        // Then
        expect(discount, equals(Money.fromDouble(20.0)));
        expect(percentage, equals(20.0));
        expect(product.hasDiscount(originalPrice), isTrue);
      });

      test('Given producto sin descuento (precio igual al original), '
          'When verifica descuento, '
          'Then descuento es cero', () {
        // Given
        final product = createTestProductAggregate(price: 100.0);
        final originalPrice = Money.fromDouble(100.0);

        // When
        final discount = product.calculateDiscount(originalPrice);

        // Then
        expect(discount, equals(Money.zero));
        expect(product.hasDiscount(originalPrice), isFalse);
      });
    });

    group('Scenario: AC2 - Identificar producto destacado', () {
      test('Given producto con rating 4.7 y 250 reseñas, '
          'When evalúa si es destacado, '
          'Then es altamente calificado y tiene suficientes reseñas', () {
        // Given
        final product = createTestProductAggregate(
          ratingRate: 4.7,
          ratingCount: 250,
        );

        // When & Then
        expect(product.isHighlyRated(), isTrue);
        expect(product.hasEnoughReviews(), isTrue);
      });

      test('Given producto con rating 4.8 pero solo 5 reseñas, '
          'When evalúa si es destacado, '
          'Then es altamente calificado pero sin suficientes reseñas', () {
        // Given
        final product = createTestProductAggregate(
          ratingRate: 4.8,
          ratingCount: 5,
        );

        // When & Then
        expect(product.isHighlyRated(), isTrue);
        expect(product.hasEnoughReviews(), isFalse);
      });

      test('Given producto con rating 3.5 y muchas reseñas, '
          'When evalúa si es destacado, '
          'Then NO es altamente calificado', () {
        // Given
        final product = createTestProductAggregate(
          ratingRate: 3.5,
          ratingCount: 500,
        );

        // When & Then
        expect(product.isHighlyRated(), isFalse);
        expect(product.hasEnoughReviews(), isTrue);
      });
    });

    group('Scenario: AC3 - Verificar categoría del producto', () {
      test('Given producto en categoría "electronics", '
          'When verifica categoría, '
          'Then confirma pertenencia (case-insensitive)', () {
        // Given
        final product = createTestProductAggregate(category: 'electronics');

        // When & Then
        expect(product.isInCategory('electronics'), isTrue);
        expect(product.isInCategory('ELECTRONICS'), isTrue);
        expect(product.isInCategory('Electronics'), isTrue);
        expect(product.isInCategory('clothing'), isFalse);
      });
    });

    group('Scenario: AC4 - Registrar visualización de producto', () {
      test('Given producto en catálogo, '
          'When usuario visualiza producto, '
          'Then se genera evento con ID del producto', () {
        // Given
        final product = createTestProductAggregate(id: 42);

        // When
        final event = product.recordView();

        // Then
        expect(event, isA<ProductViewedEvent>());
        expect(event.productId, equals(ProductId(42)));
        expect(event.eventId, isNotEmpty);
        expect(
          event.occurredAt.isBefore(
            DateTime.now().add(const Duration(seconds: 1)),
          ),
          isTrue,
        );
      });

      test('Given producto visualizado múltiples veces, '
          'When genera eventos, '
          'Then cada evento tiene ID único', () {
        // Given
        final product = createTestProductAggregate();

        // When
        final event1 = product.recordView();
        final event2 = product.recordView();

        // Then
        expect(event1.eventId, isNot(equals(event2.eventId)));
      });
    });

    group('Scenario: AC5 - Value Objects validan datos correctamente', () {
      test('ProductId rechaza valores no positivos', () {
        expect(() => ProductId(0), throwsA(isA<ArgumentError>()));
        expect(() => ProductId(-1), throwsA(isA<ArgumentError>()));
      });

      test('ProductId acepta valores positivos', () {
        expect(ProductId(1).value, equals(1));
        expect(ProductId(999).value, equals(999));
      });

      test('ProductTitle rechaza títulos vacíos', () {
        expect(() => ProductTitle(''), throwsA(isA<ArgumentError>()));
        expect(() => ProductTitle('   '), throwsA(isA<ArgumentError>()));
      });

      test('ProductTitle rechaza títulos muy largos', () {
        final longTitle = 'a' * 201;
        expect(() => ProductTitle(longTitle), throwsA(isA<ArgumentError>()));
      });

      test('Money rechaza valores negativos', () {
        expect(() => Money.fromDouble(-1), throwsA(isA<ArgumentError>()));
      });

      test('Money acepta cero y valores positivos', () {
        expect(Money.fromDouble(0).value, equals(0.0));
        expect(Money.fromDouble(99.99).value, equals(99.99));
      });

      test('Rating rechaza valores fuera de rango', () {
        expect(() => Rating(rate: -1, count: 0), throwsA(isA<ArgumentError>()));
        expect(() => Rating(rate: 6, count: 0), throwsA(isA<ArgumentError>()));
        expect(
          () => Rating(rate: 4.5, count: -1),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
