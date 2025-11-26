import 'package:fase_2_consumo_api/src/core/errors/failure.dart';

/// Fallo que representa un recurso no encontrado.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
