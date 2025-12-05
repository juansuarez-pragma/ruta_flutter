import 'package:equatable/equatable.dart';

import 'package:fase_2_consumo_api/src/domain/entities/address_entity.dart';
import 'package:fase_2_consumo_api/src/domain/entities/name_entity.dart';

/// Entidad que representa un usuario del sistema.
///
/// Es inmutable y usa [Equatable] para comparación por valor.
class UserEntity extends Equatable {
  /// Identificador único del usuario.
  final int id;

  /// Correo electrónico del usuario.
  final String email;

  /// Nombre de usuario para login.
  final String username;

  /// Nombre completo del usuario.
  final NameEntity name;

  /// Dirección postal del usuario.
  final AddressEntity address;

  /// Teléfono de contacto.
  final String phone;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.address,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, email, username, name, address, phone];
}
