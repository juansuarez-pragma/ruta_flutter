/// Excepción base inmutable para errores de la aplicación.
abstract class AppException implements Exception {
  final String? message;

  const AppException([this.message]);

  @override
  String toString() => message ?? runtimeType.toString();
}

/// Excepción lanzada cuando el servidor retorna un error (5xx).
class ServerException extends AppException {
  const ServerException([super.message]);
}

/// Excepción lanzada cuando el recurso no se encuentra (404).
class NotFoundException extends AppException {
  const NotFoundException([super.message]);
}

/// Excepción lanzada cuando hay un error del cliente (4xx).
class ClientException extends AppException {
  const ClientException([super.message]);
}

/// Excepción lanzada cuando hay problemas de conexión.
class ConnectionException extends AppException {
  const ConnectionException([super.message]);
}