import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/core/network/http_status_codes.dart';

void main() {
  late ApiResponseHandler handler;

  setUp(() {
    handler = ApiResponseHandler();
  });

  group('ApiResponseHandler', () {
    group('respuestas exitosas (2xx)', () {
      test('no hace nada para respuesta 200 OK', () {
        // Arrange
        final response = http.Response('{"data": "ok"}', HttpStatusCodes.ok);

        // Act & Assert - no debería lanzar excepción
        expect(() => handler.handleResponse(response), returnsNormally);
      });

      test('no hace nada para respuesta 201 Created', () {
        // Arrange
        final response = http.Response('{}', HttpStatusCodes.created);

        // Act & Assert
        expect(() => handler.handleResponse(response), returnsNormally);
      });

      test('no hace nada para respuesta 204 No Content', () {
        // Arrange
        final response = http.Response('', HttpStatusCodes.noContent);

        // Act & Assert
        expect(() => handler.handleResponse(response), returnsNormally);
      });

      test('no hace nada para cualquier código 2xx', () {
        // Arrange
        final response = http.Response('', HttpStatusCodes.accepted);

        // Act & Assert
        expect(() => handler.handleResponse(response), returnsNormally);
      });
    });

    group('errores del cliente (4xx)', () {
      test('lanza NotFoundException para 404 Not Found', () {
        // Arrange
        final response = http.Response('Not Found', HttpStatusCodes.notFound);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<NotFoundException>()),
        );
      });

      test('lanza ClientException para 400 Bad Request', () {
        // Arrange
        final response = http.Response('Bad Request', HttpStatusCodes.badRequest);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ClientException>()),
        );
      });

      test('lanza ClientException para 401 Unauthorized', () {
        // Arrange
        final response = http.Response('Unauthorized', HttpStatusCodes.unauthorized);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ClientException>()),
        );
      });

      test('lanza ClientException para 403 Forbidden', () {
        // Arrange
        final response = http.Response('Forbidden', HttpStatusCodes.forbidden);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ClientException>()),
        );
      });

      test('lanza ClientException para código 4xx no mapeado explícitamente', () {
        // Arrange - 422 Unprocessable Entity no está en el mapa
        final response = http.Response('Unprocessable Entity', 422);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ClientException>()),
        );
      });

      test('lanza ClientException para 429 Too Many Requests', () {
        // Arrange
        final response = http.Response('Rate Limited', HttpStatusCodes.tooManyRequests);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ClientException>()),
        );
      });
    });

    group('errores del servidor (5xx)', () {
      test('lanza ServerException para 500 Internal Server Error', () {
        // Arrange
        final response = http.Response('Server Error', HttpStatusCodes.internalServerError);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ServerException>()),
        );
      });

      test('lanza ServerException para código 5xx no mapeado explícitamente', () {
        // Arrange - 502 Bad Gateway no está en el mapa
        final response = http.Response('Bad Gateway', HttpStatusCodes.badGateway);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ServerException>()),
        );
      });

      test('lanza ServerException para 503 Service Unavailable', () {
        // Arrange
        final response = http.Response('Service Unavailable', HttpStatusCodes.serviceUnavailable);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('códigos inesperados', () {
      test('lanza ServerException para código no esperado como fallback', () {
        // Arrange - código 600 no existe en HTTP estándar
        final response = http.Response('Unknown', 600);

        // Act & Assert
        expect(
          () => handler.handleResponse(response),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });

  group('HttpStatusCodes', () {
    group('isSuccess', () {
      test('retorna true para 200', () {
        expect(HttpStatusCodes.isSuccess(200), isTrue);
      });

      test('retorna true para 201', () {
        expect(HttpStatusCodes.isSuccess(201), isTrue);
      });

      test('retorna true para 299', () {
        expect(HttpStatusCodes.isSuccess(299), isTrue);
      });

      test('retorna false para 199', () {
        expect(HttpStatusCodes.isSuccess(199), isFalse);
      });

      test('retorna false para 300', () {
        expect(HttpStatusCodes.isSuccess(300), isFalse);
      });
    });

    group('isClientError', () {
      test('retorna true para 400', () {
        expect(HttpStatusCodes.isClientError(400), isTrue);
      });

      test('retorna true para 404', () {
        expect(HttpStatusCodes.isClientError(404), isTrue);
      });

      test('retorna true para 499', () {
        expect(HttpStatusCodes.isClientError(499), isTrue);
      });

      test('retorna false para 399', () {
        expect(HttpStatusCodes.isClientError(399), isFalse);
      });

      test('retorna false para 500', () {
        expect(HttpStatusCodes.isClientError(500), isFalse);
      });
    });

    group('isServerError', () {
      test('retorna true para 500', () {
        expect(HttpStatusCodes.isServerError(500), isTrue);
      });

      test('retorna true para 503', () {
        expect(HttpStatusCodes.isServerError(503), isTrue);
      });

      test('retorna true para 599', () {
        expect(HttpStatusCodes.isServerError(599), isTrue);
      });

      test('retorna false para 499', () {
        expect(HttpStatusCodes.isServerError(499), isFalse);
      });

      test('retorna false para 600', () {
        expect(HttpStatusCodes.isServerError(600), isFalse);
      });
    });
  });
}
