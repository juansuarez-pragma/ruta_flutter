import 'package:fase_2_consumo_api/src/domain/entities/geolocation_entity.dart';

/// Modelo de datos para coordenadas geográficas.
///
/// Maneja la serialización/deserialización de JSON y la conversión
/// a la entidad de dominio [GeolocationEntity].
class GeolocationModel {
  final String lat;
  final String long;

  const GeolocationModel({
    required this.lat,
    required this.long,
  });

  /// Crea un [GeolocationModel] a partir de un mapa JSON.
  factory GeolocationModel.fromJson(Map<String, dynamic> json) {
    return GeolocationModel(
      lat: json['lat'] as String,
      long: json['long'] as String,
    );
  }

  /// Convierte este modelo a una entidad de dominio.
  GeolocationEntity toEntity() {
    return GeolocationEntity(
      lat: lat,
      long: long,
    );
  }
}
