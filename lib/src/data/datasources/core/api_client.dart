/// Cliente HTTP abstracto que encapsula la lógica común de peticiones a la API.
///
/// Define el contrato para realizar peticiones HTTP de forma genérica,
/// manejando automáticamente errores, parseo de JSON y construcción de URLs.
///
/// Esto permite que los DataSources específicos solo se enfoquen en
/// definir endpoints y mapear respuestas a modelos.
abstract class ApiClient {
  /// Realiza una petición GET y retorna el resultado parseado.
  ///
  /// [endpoint] es la ruta relativa del recurso (ej. '/products').
  /// [fromJson] es la función que convierte el JSON decodificado al tipo [T].
  ///
  /// Lanza excepciones tipadas según el código de respuesta HTTP.
  Future<T> get<T>({
    required String endpoint,
    required T Function(dynamic json) fromJson,
  });

  /// Realiza una petición GET que retorna una lista de elementos.
  ///
  /// [endpoint] es la ruta relativa del recurso.
  /// [fromJsonList] convierte cada elemento del array JSON al tipo [T].
  Future<List<T>> getList<T>({
    required String endpoint,
    required T Function(Map<String, dynamic> json) fromJsonList,
  });

  /// Realiza una petición GET que retorna una lista de tipos primitivos.
  ///
  /// Útil para endpoints que retornan arrays simples (ej. lista de strings).
  Future<List<T>> getPrimitiveList<T>({required String endpoint});
}
