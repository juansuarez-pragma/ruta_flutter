import 'package:fase_2_consumo_api/src/core/errors/failure.dart';

/// Fallo que representa un error del servidor.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
