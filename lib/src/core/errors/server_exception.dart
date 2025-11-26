import 'package:fase_2_consumo_api/src/core/errors/app_exception.dart';

/// Excepción lanzada cuando el servidor retorna un error (5xx).
class ServerException extends AppException {
  const ServerException([super.message]);
}
