/// Excepción inmutable lanzada cuando hay errores de configuración de entorno.
class EnvConfigException implements Exception {
  final String message;

  const EnvConfigException(this.message);

  @override
  String toString() => 'EnvConfigException: $message';
}
