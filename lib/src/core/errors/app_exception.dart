/// Excepción base inmutable para errores de la aplicación.
abstract class AppException implements Exception {
  final String? message;

  const AppException([this.message]);

  @override
  String toString() => message ?? runtimeType.toString();
}
