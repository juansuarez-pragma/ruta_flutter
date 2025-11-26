import 'package:fase_2_consumo_api/src/core/errors/app_exception.dart';

/// Excepción lanzada cuando hay un error del cliente (4xx).
class ClientException extends AppException {
  const ClientException([super.message]);
}
