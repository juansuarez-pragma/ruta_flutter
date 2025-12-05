import 'package:equatable/equatable.dart';

/// Entidad que representa el nombre de un usuario.
///
/// Value Object inmutable que contiene nombre y apellido.
class NameEntity extends Equatable {
  /// Nombre de pila.
  final String firstname;

  /// Apellido.
  final String lastname;

  const NameEntity({
    required this.firstname,
    required this.lastname,
  });

  @override
  List<Object?> get props => [firstname, lastname];
}
