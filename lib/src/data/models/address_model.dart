import 'package:fase_2_consumo_api/src/data/models/geolocation_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/address_entity.dart';

/// Modelo de datos para dirección de usuario.
///
/// Maneja la serialización/deserialización de JSON y la conversión
/// a la entidad de dominio [AddressEntity].
class AddressModel {
  final String city;
  final String street;
  final int number;
  final String zipcode;
  final GeolocationModel geolocation;

  const AddressModel({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
    required this.geolocation,
  });

  /// Crea un [AddressModel] a partir de un mapa JSON.
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      city: json['city'] as String,
      street: json['street'] as String,
      number: json['number'] as int,
      zipcode: json['zipcode'] as String,
      geolocation: GeolocationModel.fromJson(
        json['geolocation'] as Map<String, dynamic>,
      ),
    );
  }

  /// Convierte este modelo a una entidad de dominio.
  AddressEntity toEntity() {
    return AddressEntity(
      city: city,
      street: street,
      number: number,
      zipcode: zipcode,
      geolocation: geolocation.toEntity(),
    );
  }
}
