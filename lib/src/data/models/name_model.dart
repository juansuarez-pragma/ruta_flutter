import 'package:fase_2_consumo_api/src/domain/entities/name_entity.dart';

/// Modelo de datos para nombre de usuario.
///
/// Maneja la serialización/deserialización de JSON y la conversión
/// a la entidad de dominio [NameEntity].
class NameModel {
  final String firstname;
  final String lastname;

  const NameModel({
    required this.firstname,
    required this.lastname,
  });

  /// Crea un [NameModel] a partir de un mapa JSON.
  factory NameModel.fromJson(Map<String, dynamic> json) {
    return NameModel(
      firstname: json['firstname'] as String,
      lastname: json['lastname'] as String,
    );
  }

  /// Convierte este modelo a una entidad de dominio.
  NameEntity toEntity() {
    return NameEntity(
      firstname: firstname,
      lastname: lastname,
    );
  }
}
