import 'package:equatable/equatable.dart';

/// Entidad que representa las coordenadas geográficas.
///
/// Value Object inmutable que contiene latitud y longitud.
class GeolocationEntity extends Equatable {
  /// Latitud de la ubicación.
  final String lat;

  /// Longitud de la ubicación.
  final String long;

  const GeolocationEntity({
    required this.lat,
    required this.long,
  });

  @override
  List<Object?> get props => [lat, long];
}
