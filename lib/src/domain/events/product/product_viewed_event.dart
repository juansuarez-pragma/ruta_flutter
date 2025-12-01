import '../../value_objects/product/product_id.dart';
import '../domain_event.dart';

/// Evento emitido cuando un usuario visualiza un producto.
///
/// Este evento puede ser utilizado para:
/// - Registrar métricas de visualización
/// - Alimentar sistemas de recomendación
/// - Auditoría de actividad
///
/// Ejemplo:
/// ```dart
/// final event = ProductViewedEvent(productId: ProductId(42));
/// eventDispatcher.dispatch(event);
/// ```
class ProductViewedEvent extends DomainEvent {
  /// ID del producto que fue visualizado.
  final ProductId productId;

  /// Crea un evento de visualización de producto.
  ProductViewedEvent({required this.productId});

  @override
  List<Object?> get props => [...super.props, productId];

  @override
  String toString() =>
      'ProductViewedEvent(eventId: $eventId, productId: ${productId.value}, occurredAt: $occurredAt)';
}
