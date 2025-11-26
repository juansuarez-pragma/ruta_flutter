import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';

class ApiResponseHandler {
  void handleResponse(http.Response response) {
    final int statusCode = response.statusCode;

    // Si la respuesta es exitosa, no hacemos nada.
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    // Estrategias para códigos de error específicos
    final strategy = _errorStrategies[statusCode];
    if (strategy != null) {
      strategy();
    }

    // Estrategias de respaldo por rangos
    if (statusCode >= 500) {
      throw ServerException();
    }
    if (statusCode >= 400) {
      throw ClientException();
    }

    // Fallback final para cualquier otro caso
    throw ServerException();
  }

  // Mapa que implementa el Patrón Strategy
  static final Map<int, Function> _errorStrategies = {
    400: () => throw ClientException(),
    401: () => throw ClientException(), // Podría ser UnauthorizedException
    403: () => throw ClientException(), // Podría ser ForbiddenException
    404: () => throw NotFoundException(),
    500: () => throw ServerException(),
  };
}
