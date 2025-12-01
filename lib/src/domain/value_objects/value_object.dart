import 'package:equatable/equatable.dart';

/// Clase base abstracta para Value Objects.
///
/// Un Value Object es un objeto inmutable que se identifica por su valor,
/// no por su identidad. Dos Value Objects con el mismo valor son considerados
/// iguales.
///
/// Extiende [Equatable] para comparación automática por valor.
///
/// Ejemplo de uso:
/// ```dart
/// class Email extends ValueObject<String> {
///   Email(String value) : super(_validate(value));
///
///   static String _validate(String value) {
///     if (!value.contains('@')) {
///       throw ArgumentError('Email inválido');
///     }
///     return value;
///   }
/// }
/// ```
abstract class ValueObject<T> extends Equatable {
  /// El valor encapsulado por este Value Object.
  final T value;

  /// Crea un Value Object con el valor especificado.
  const ValueObject(this.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '$runtimeType($value)';
}
