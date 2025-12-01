import '../value_object.dart';

/// Value Object que representa el identificador único de un producto.
///
/// Garantiza que el ID sea un entero positivo mayor que cero.
///
/// Ejemplo:
/// ```dart
/// final id = ProductId(42);
/// print(id.value); // 42
/// ```
class ProductId extends ValueObject<int> {
  /// Crea un [ProductId] con el valor especificado.
  ///
  /// Lanza [ArgumentError] si [value] es menor o igual a cero.
  ProductId(int value) : super(_validate(value));

  static int _validate(int value) {
    if (value <= 0) {
      throw ArgumentError.value(
        value,
        'value',
        'El ID del producto debe ser un entero positivo mayor que cero',
      );
    }
    return value;
  }
}
