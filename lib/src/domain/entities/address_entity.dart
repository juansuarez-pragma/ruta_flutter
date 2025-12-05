import 'package:equatable/equatable.dart';

import 'package:fase_2_consumo_api/src/domain/entities/geolocation_entity.dart';

/// Entidad que representa la dirección de un usuario.
///
/// Value Object inmutable que contiene los datos de ubicación postal.
class AddressEntity extends Equatable {
  /// Ciudad de residencia.
  final String city;

  /// Nombre de la calle.
  final String street;

  /// Número de la dirección.
  final int number;

  /// Código postal.
  final String zipcode;

  /// Coordenadas geográficas de la dirección.
  final GeolocationEntity geolocation;

  const AddressEntity({
    required this.city,
    required this.street,
    required this.number,
    required this.zipcode,
    required this.geolocation,
  });

  @override
  List<Object?> get props => [city, street, number, zipcode, geolocation];
}
