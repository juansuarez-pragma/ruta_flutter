import 'package:fase_2_consumo_api/src/core/errors/app_exception.dart';

/// Excepción lanzada cuando el recurso no se encuentra (404).
class NotFoundException extends AppException {
  const NotFoundException([super.message]);
}
