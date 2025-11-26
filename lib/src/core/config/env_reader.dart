/// Interfaz abstracta para leer variables de entorno.
///
/// Define el contrato que cualquier implementación de lectura de
/// variables de entorno debe cumplir. Esto permite cambiar la
/// librería subyacente (dotenv, flutter_dotenv, etc.) sin modificar
/// el código que consume la configuración.
///
/// Basado en el patrón Adapter para desacoplar la implementación.
abstract class EnvReader {
  /// Carga las variables de entorno desde la fuente especificada.
  ///
  /// [path] es la ruta al archivo de configuración.
  Future<void> load(String path);

  /// Obtiene el valor de una variable de entorno.
  ///
  /// Retorna `null` si la variable no existe.
  String? operator [](String key);

  /// Verifica si una variable de entorno existe y tiene valor.
  bool containsKey(String key);
}
