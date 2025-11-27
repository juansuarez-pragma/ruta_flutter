import 'package:fase_2_consumo_api/src/core/errors/app_exception.dart';

/// Excepción lanzada cuando hay problemas de conexión.
///
/// Puede contener información de diagnóstico como la URI que falló
/// y el mensaje del error original para facilitar debugging.
class ConnectionException extends AppException {
  /// URI que causó el error de conexión (opcional).
  final Uri? uri;

  /// Mensaje del error original (opcional).
  final String? originalError;

  const ConnectionException({String? message, this.uri, this.originalError})
    : super(message);

  @override
  String toString() {
    final buffer = StringBuffer('ConnectionException');
    if (message != null) {
      buffer.write(': $message');
    }
    if (uri != null) {
      buffer.write(' [URI: $uri]');
    }
    if (originalError != null) {
      buffer.write(' (Original: $originalError)');
    }
    return buffer.toString();
  }
}
