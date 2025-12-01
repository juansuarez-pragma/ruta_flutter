import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los eventos de dominio.
///
/// Un evento de dominio representa algo significativo que ocurrió en el
/// dominio de negocio. Los eventos son inmutables y contienen información
/// sobre cuándo ocurrieron.
///
/// Cada evento tiene:
/// - [eventId]: Identificador único del evento
/// - [occurredAt]: Momento en que ocurrió el evento
///
/// Ejemplo de uso:
/// ```dart
/// class OrderPlacedEvent extends DomainEvent {
///   final OrderId orderId;
///   final Money total;
///
///   OrderPlacedEvent({required this.orderId, required this.total});
/// }
/// ```
abstract class DomainEvent extends Equatable {
  /// Identificador único del evento.
  final String eventId;

  /// Momento en que ocurrió el evento.
  final DateTime occurredAt;

  /// Crea un nuevo evento de dominio.
  ///
  /// Genera automáticamente un [eventId] único y registra [occurredAt]
  /// como el momento actual.
  DomainEvent() : eventId = _generateEventId(), occurredAt = DateTime.now();

  /// Genera un ID único para el evento.
  static String _generateEventId() {
    final now = DateTime.now();
    final random = now.microsecondsSinceEpoch.toRadixString(36);
    return '${now.millisecondsSinceEpoch.toRadixString(36)}-$random';
  }

  @override
  List<Object?> get props => [eventId];

  @override
  String toString() =>
      '$runtimeType(eventId: $eventId, occurredAt: $occurredAt)';
}
