/// Tests para [ProductViewedEvent].
///
/// ESPECIFICACIÓN: ProductViewedEvent
///
/// Responsabilidad: Representar el evento de cuando un usuario visualiza un producto.
///
/// Propiedades:
///   - productId: ProductId del producto visualizado
///   - Hereda eventId y occurredAt de DomainEvent
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/events/domain_event.dart';
import 'package:fase_2_consumo_api/src/domain/events/product/product_viewed_event.dart';
import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_id.dart';

void main() {
  group('ProductViewedEvent', () {
    test('es un DomainEvent', () {
      // Arrange & Act
      final event = ProductViewedEvent(productId: ProductId(1));

      // Assert
      expect(event, isA<DomainEvent>());
    });

    test('almacena el productId correctamente', () {
      // Arrange
      final productId = ProductId(42);

      // Act
      final event = ProductViewedEvent(productId: productId);

      // Assert
      expect(event.productId, equals(productId));
    });

    test('tiene eventId único', () {
      // Arrange
      final productId = ProductId(1);

      // Act
      final event1 = ProductViewedEvent(productId: productId);
      final event2 = ProductViewedEvent(productId: productId);

      // Assert
      expect(event1.eventId, isNot(equals(event2.eventId)));
    });

    test('registra occurredAt', () {
      // Arrange
      final before = DateTime.now();

      // Act
      final event = ProductViewedEvent(productId: ProductId(1));
      final after = DateTime.now();

      // Assert
      expect(
        event.occurredAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        event.occurredAt.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });

    test('toString contiene información del evento', () {
      // Arrange
      final event = ProductViewedEvent(productId: ProductId(42));

      // Act
      final str = event.toString();

      // Assert
      expect(str, contains('ProductViewedEvent'));
    });
  });
}
