import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';

void main() {
  group('Exceptions', () {
    group('AppException', () {
      test('toString retorna el mensaje cuando está presente', () {
        const exception = ServerException('Error message');
        expect(exception.toString(), 'Error message');
      });

      test('toString retorna el tipo cuando no hay mensaje', () {
        const exception = ServerException();
        expect(exception.toString(), 'ServerException');
      });
    });

    group('ServerException', () {
      test('almacena mensaje opcional', () {
        const exception = ServerException('Internal server error');
        expect(exception.message, 'Internal server error');
      });
    });

    group('NotFoundException', () {
      test('almacena mensaje opcional', () {
        const exception = NotFoundException('Resource not found');
        expect(exception.message, 'Resource not found');
      });
    });

    group('ClientException', () {
      test('almacena mensaje opcional', () {
        const exception = ClientException('Bad request');
        expect(exception.message, 'Bad request');
      });
    });

    group('ConnectionException', () {
      test('almacena uri y originalError', () {
        final uri = Uri.parse('https://api.example.com/products');
        final exception = ConnectionException(
          uri: uri,
          originalError: 'Connection refused',
        );

        expect(exception.uri, uri);
        expect(exception.originalError, 'Connection refused');
      });

      test('toString incluye todos los campos cuando están presentes', () {
        final exception = ConnectionException(
          message: 'Connection failed',
          uri: Uri.parse('https://api.example.com'),
          originalError: 'Timeout',
        );

        final result = exception.toString();
        expect(result, contains('ConnectionException'));
        expect(result, contains('Connection failed'));
        expect(result, contains('api.example.com'));
      });

      test('toString solo muestra tipo cuando no hay datos', () {
        const exception = ConnectionException();
        expect(exception.toString(), 'ConnectionException');
      });
    });
  });
}
