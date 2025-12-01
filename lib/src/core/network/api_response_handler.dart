import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/network/http_status_codes.dart';

/// Maneja las respuestas HTTP y lanza excepciones según el código de estado.
///
/// Referencia de códigos HTTP:
/// - 2xx: Éxito (no lanza excepción)
/// - 4xx: Error del cliente (la solicitud es incorrecta)
/// - 5xx: Error del servidor (el servidor falló al procesar)
class ApiResponseHandler {
  /// Procesa la respuesta HTTP y lanza excepciones si hay errores.
  ///
  /// No hace nada si el código de estado indica éxito (2xx).
  /// Para códigos de error, busca primero una estrategia específica
  /// y luego aplica manejo por rangos.
  void handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    // 2xx - Respuestas exitosas: no hacemos nada
    if (HttpStatusCodes.isSuccess(statusCode)) {
      return;
    }

    // Buscar estrategia específica para el código
    final strategy = _errorStrategies[statusCode];
    if (strategy != null) {
      strategy();
      return;
    }

    // 5xx - Errores del servidor
    if (HttpStatusCodes.isServerError(statusCode)) {
      throw ServerException();
    }

    // 4xx - Errores del cliente
    if (HttpStatusCodes.isClientError(statusCode)) {
      throw ClientException();
    }

    // Fallback para cualquier otro código no esperado
    throw ServerException();
  }

  /// Mapa de estrategias para códigos HTTP específicos.
  ///
  /// Permite manejar códigos individuales con excepciones específicas.
  /// Los códigos no listados aquí se manejan por rangos en [handleResponse].
  static final Map<int, Function> _errorStrategies = {
    // 400 Bad Request: solicitud mal formada o inválida
    HttpStatusCodes.badRequest: () => throw ClientException(),

    // 401 Unauthorized: requiere autenticación
    HttpStatusCodes.unauthorized: () => throw ClientException(),

    // 403 Forbidden: autenticado pero sin permisos
    HttpStatusCodes.forbidden: () => throw ClientException(),

    // 404 Not Found: recurso no existe
    HttpStatusCodes.notFound: () => throw NotFoundException(),

    // 500 Internal Server Error: error genérico del servidor
    HttpStatusCodes.internalServerError: () => throw ServerException(),
  };
}
