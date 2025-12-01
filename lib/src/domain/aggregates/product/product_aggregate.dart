import 'package:equatable/equatable.dart';

import '../../events/product/product_viewed_event.dart';
import '../../value_objects/product/product_id.dart';
import '../../value_objects/product/product_title.dart';
import '../../value_objects/shared/money.dart';

/// Aggregate Root que encapsula un producto y sus comportamientos de dominio.
///
/// El ProductAggregate es el punto de entrada para todas las operaciones
/// relacionadas con un producto. Garantiza la consistencia del estado
/// y encapsula la lógica de negocio.
///
/// Propiedades (usando Value Objects):
/// - [id]: Identificador único del producto
/// - [title]: Título validado del producto
/// - [price]: Precio actual (nunca negativo)
/// - [description]: Descripción del producto
/// - [category]: Categoría a la que pertenece
/// - [image]: URL de la imagen
/// - [rating]: Calificación embebida (rate y count)
///
/// Comportamientos de dominio:
/// - [hasDiscount]: Verifica si tiene descuento respecto a precio original
/// - [calculateDiscount]: Calcula el monto del descuento
/// - [discountPercentage]: Calcula el porcentaje de descuento
/// - [isInCategory]: Verifica si pertenece a una categoría
/// - [recordView]: Registra una visualización emitiendo un evento
/// - [isHighlyRated]: Verifica si tiene alta calificación
/// - [hasEnoughReviews]: Verifica si tiene suficientes reseñas
///
/// Ejemplo:
/// ```dart
/// final product = ProductAggregate(
///   id: ProductId(1),
///   title: ProductTitle('Laptop Gaming'),
///   price: Money.fromDouble(999.99),
///   description: 'Laptop de alto rendimiento',
///   category: 'electronics',
///   image: 'https://example.com/laptop.jpg',
///   rating: Rating(rate: 4.5, count: 150),
/// );
///
/// if (product.hasDiscount(Money.fromDouble(1199.99))) {
///   print('Descuento: ${product.discountPercentage(originalPrice)}%');
/// }
/// ```
class ProductAggregate extends Equatable {
  /// Identificador único del producto.
  final ProductId id;

  /// Título del producto (validado, no vacío, máx 200 caracteres).
  final ProductTitle title;

  /// Precio actual del producto (nunca negativo).
  final Money price;

  /// Descripción detallada del producto.
  final String description;

  /// Categoría a la que pertenece el producto.
  final String category;

  /// URL de la imagen del producto.
  final String image;

  /// Calificación del producto (rate y count).
  final Rating rating;

  /// Crea un nuevo ProductAggregate.
  const ProductAggregate({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  /// Verifica si el producto tiene descuento respecto al precio original.
  ///
  /// Retorna `true` si el precio actual es menor que [originalPrice].
  bool hasDiscount(Money originalPrice) {
    return price < originalPrice;
  }

  /// Calcula el monto del descuento respecto al precio original.
  ///
  /// Retorna [Money.zero] si no hay descuento (precio actual >= original).
  Money calculateDiscount(Money originalPrice) {
    if (!hasDiscount(originalPrice)) {
      return Money.zero;
    }
    return originalPrice.subtract(price);
  }

  /// Calcula el porcentaje de descuento respecto al precio original.
  ///
  /// Retorna 0.0 si no hay descuento.
  /// El resultado se redondea a 2 decimales.
  double discountPercentage(Money originalPrice) {
    if (!hasDiscount(originalPrice)) {
      return 0.0;
    }
    final discount = calculateDiscount(originalPrice);
    final percentage = (discount.value / originalPrice.value) * 100;
    return double.parse(percentage.toStringAsFixed(2));
  }

  /// Verifica si el producto pertenece a la categoría especificada.
  ///
  /// La comparación es case-insensitive.
  bool isInCategory(String categoryToCheck) {
    return category.toLowerCase() == categoryToCheck.toLowerCase();
  }

  /// Registra una visualización del producto.
  ///
  /// Retorna un [ProductViewedEvent] que puede ser despachado
  /// a un sistema de eventos para métricas, recomendaciones, etc.
  ProductViewedEvent recordView() {
    return ProductViewedEvent(productId: id);
  }

  /// Verifica si el producto tiene una calificación alta.
  ///
  /// Por defecto considera "alta" una calificación >= 4.0.
  /// Se puede personalizar con [threshold].
  bool isHighlyRated({double threshold = 4.0}) {
    return rating.rate >= threshold;
  }

  /// Verifica si el producto tiene suficientes reseñas.
  ///
  /// Por defecto requiere al menos 10 reseñas.
  /// Se puede personalizar con [minimumReviews].
  bool hasEnoughReviews({int minimumReviews = 10}) {
    return rating.count >= minimumReviews;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    price,
    description,
    category,
    image,
    rating,
  ];

  @override
  String toString() =>
      'ProductAggregate(id: ${id.value}, title: ${title.value}, price: $price)';
}

/// Value Object que representa la calificación de un producto.
///
/// Encapsula la tasa de calificación (0-5) y la cantidad de reseñas.
///
/// Validaciones:
/// - [rate] debe estar entre 0 y 5 (inclusive)
/// - [count] debe ser no negativo
class Rating extends Equatable {
  /// Calificación promedio (0-5).
  final double rate;

  /// Cantidad de reseñas.
  final int count;

  /// Crea un nuevo Rating.
  ///
  /// Lanza [ArgumentError] si:
  /// - [rate] es menor a 0 o mayor a 5
  /// - [count] es negativo
  Rating({required double rate, required int count})
    : rate = _validateRate(rate),
      count = _validateCount(count);

  static double _validateRate(double rate) {
    if (rate < 0 || rate > 5) {
      throw ArgumentError.value(
        rate,
        'rate',
        'La calificación debe estar entre 0 y 5',
      );
    }
    return rate;
  }

  static int _validateCount(int count) {
    if (count < 0) {
      throw ArgumentError.value(
        count,
        'count',
        'El conteo de reseñas no puede ser negativo',
      );
    }
    return count;
  }

  @override
  List<Object?> get props => [rate, count];

  @override
  String toString() => 'Rating(rate: $rate, count: $count)';
}
