/// Tests para [DomainEvent] base.
///
/// ESPECIFICACIÓN: DomainEvent
///
/// Responsabilidad: Clase base para todos los eventos de dominio.
///
/// Propiedades:
///   - eventId: String único generado automáticamente
///   - occurredAt: DateTime de cuando ocurrió el evento
///
/// Invariantes:
///   - eventId nunca es vacío
///   - occurredAt siempre tiene un valor
///   - Cada instancia tiene un eventId único
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/events/domain_event.dart';

void main() {
  group('DomainEvent', () {
    group('propiedades', () {
      test('eventId no está vacío', () {
        // Arrange & Act
        final event = _TestDomainEvent();

        // Assert
        expect(event.eventId, isNotEmpty);
      });

      test('occurredAt tiene un valor', () {
        // Arrange & Act
        final event = _TestDomainEvent();

        // Assert
        expect(event.occurredAt, isNotNull);
      });

      test('occurredAt es cercano al momento de creación', () {
        // Arrange
        final before = DateTime.now();

        // Act
        final event = _TestDomainEvent();
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
    });

    group('unicidad', () {
      test('cada evento tiene eventId único', () {
        // Arrange & Act
        final event1 = _TestDomainEvent();
        final event2 = _TestDomainEvent();

        // Assert
        expect(event1.eventId, isNot(equals(event2.eventId)));
      });

      test('múltiples eventos tienen diferentes eventIds', () {
        // Arrange & Act
        final events = List.generate(10, (_) => _TestDomainEvent());
        final eventIds = events.map((e) => e.eventId).toSet();

        // Assert
        expect(eventIds.length, equals(10));
      });
    });

    group('igualdad', () {
      test('dos eventos diferentes no son iguales', () {
        // Arrange & Act
        final event1 = _TestDomainEvent();
        final event2 = _TestDomainEvent();

        // Assert
        expect(event1, isNot(equals(event2)));
      });

      test('mismo evento es igual a sí mismo', () {
        // Arrange & Act
        final event = _TestDomainEvent();

        // Assert
        expect(event, equals(event));
      });
    });
  });
}

/// Evento de prueba para testear la clase base.
class _TestDomainEvent extends DomainEvent {}
