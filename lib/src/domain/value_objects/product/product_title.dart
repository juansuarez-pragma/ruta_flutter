import '../value_object.dart';

/// Value Object que representa el título de un producto.
///
/// Garantiza que:
/// - No esté vacío
/// - No sea solo espacios en blanco
/// - No exceda 200 caracteres
///
/// Ejemplo:
/// ```dart
/// final title = ProductTitle('Laptop Gaming Pro');
/// print(title.value); // 'Laptop Gaming Pro'
/// ```
class ProductTitle extends ValueObject<String> {
  /// Longitud máxima permitida para el título.
  static const int maxLength = 200;

  /// Crea un [ProductTitle] con el valor especificado.
  ///
  /// El valor es recortado (trim) automáticamente.
  /// Lanza [ArgumentError] si:
  /// - El valor está vacío o es solo espacios
  /// - El valor excede [maxLength] caracteres
  ProductTitle(String value) : super(_validate(value));

  static String _validate(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        value,
        'value',
        'El título del producto no puede estar vacío',
      );
    }

    if (trimmed.length > maxLength) {
      throw ArgumentError.value(
        value,
        'value',
        'El título del producto no puede exceder $maxLength caracteres',
      );
    }

    return trimmed;
  }
}
