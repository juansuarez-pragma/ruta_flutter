import 'package:fase_2_consumo_api/src/core/errors/app_exception.dart';

/// Excepción lanzada cuando hay problemas de conexión.
class ConnectionException extends AppException {
  const ConnectionException([super.message]);
}
