import '../value_object.dart';

/// Value Object que representa un valor monetario no negativo.
///
/// Garantiza que:
/// - El valor nunca sea negativo
/// - Tenga precisión de 2 decimales
///
/// Proporciona operaciones aritméticas seguras que mantienen las invariantes.
///
/// Ejemplo:
/// ```dart
/// final precio = Money.fromDouble(99.99);
/// final descuento = Money.fromDouble(10.00);
/// final precioFinal = precio.subtract(descuento); // $89.99
/// ```
class Money extends ValueObject<double> implements Comparable<Money> {
  /// Crea un [Money] desde un valor double.
  ///
  /// El valor se redondea a 2 decimales.
  /// Lanza [ArgumentError] si [amount] es negativo.
  Money.fromDouble(double amount) : super(_validate(amount));

  /// Valor cero constante.
  static final Money zero = Money.fromDouble(0.0);

  static double _validate(double amount) {
    if (amount < 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'El valor monetario no puede ser negativo',
      );
    }
    // Redondear a 2 decimales
    return double.parse(amount.toStringAsFixed(2));
  }

  /// Suma este valor con [other].
  ///
  /// Retorna un nuevo [Money] con la suma de ambos valores.
  Money add(Money other) => Money.fromDouble(value + other.value);

  /// Resta [other] de este valor.
  ///
  /// Lanza [ArgumentError] si el resultado sería negativo.
  Money subtract(Money other) => Money.fromDouble(value - other.value);

  /// Multiplica este valor por [quantity].
  ///
  /// Útil para calcular el total de múltiples items.
  Money multiply(int quantity) => Money.fromDouble(value * quantity);

  @override
  int compareTo(Money other) => value.compareTo(other.value);

  /// Operador menor que.
  bool operator <(Money other) => compareTo(other) < 0;

  /// Operador menor o igual que.
  bool operator <=(Money other) => compareTo(other) <= 0;

  /// Operador mayor que.
  bool operator >(Money other) => compareTo(other) > 0;

  /// Operador mayor o igual que.
  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  String toString() => '\$${value.toStringAsFixed(2)}';
}
