import 'package:fase_2_consumo_api/src/data/models/address_model.dart';
import 'package:fase_2_consumo_api/src/data/models/name_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';

/// Modelo de datos para un usuario.
///
/// Maneja la serialización/deserialización de JSON y la conversión
/// a la entidad de dominio [UserEntity].
class UserModel {
  final int id;
  final String email;
  final String username;
  final String password;
  final NameModel name;
  final AddressModel address;
  final String phone;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.name,
    required this.address,
    required this.phone,
  });

  /// Crea un [UserModel] a partir de un mapa JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      name: NameModel.fromJson(json['name'] as Map<String, dynamic>),
      address: AddressModel.fromJson(json['address'] as Map<String, dynamic>),
      phone: json['phone'] as String,
    );
  }

  /// Convierte este modelo a una entidad de dominio.
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      username: username,
      name: name.toEntity(),
      address: address.toEntity(),
      phone: phone,
    );
  }
}
