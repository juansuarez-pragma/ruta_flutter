import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';

void main() {
  group('Exceptions', () {
    group('AppException', () {
      test('toString retorna el mensaje cuando está presente', () {
        // Arrange - Usamos ServerException que extiende AppException
        const exception = ServerException('Error message');

        // Assert
        expect(exception.toString(), 'Error message');
      });

      test('toString retorna el tipo cuando no hay mensaje', () {
        // Arrange
        const exception = ServerException();

        // Assert
        expect(exception.toString(), 'ServerException');
      });
    });

    group('ServerException', () {
      test('implementa Exception', () {
        // Arrange & Act
        const exception = ServerException();

        // Assert
        expect(exception, isA<Exception>());
      });

      test('extiende AppException', () {
        // Arrange & Act
        const exception = ServerException();

        // Assert
        expect(exception, isA<AppException>());
      });

      test('almacena mensaje opcional', () {
        // Arrange
        const message = 'Internal server error';
        const exception = ServerException(message);

        // Assert
        expect(exception.message, message);
      });

      test('mensaje puede ser null', () {
        // Arrange
        const exception = ServerException();

        // Assert
        expect(exception.message, isNull);
      });
    });

    group('NotFoundException', () {
      test('implementa Exception', () {
        expect(const NotFoundException(), isA<Exception>());
      });

      test('extiende AppException', () {
        expect(const NotFoundException(), isA<AppException>());
      });

      test('almacena mensaje opcional', () {
        const message = 'Resource not found';
        const exception = NotFoundException(message);
        expect(exception.message, message);
      });
    });

    group('ClientException', () {
      test('implementa Exception', () {
        expect(const ClientException(), isA<Exception>());
      });

      test('extiende AppException', () {
        expect(const ClientException(), isA<AppException>());
      });

      test('almacena mensaje opcional', () {
        const message = 'Bad request';
        const exception = ClientException(message);
        expect(exception.message, message);
      });
    });

    group('ConnectionException', () {
      test('implementa Exception', () {
        expect(const ConnectionException(), isA<Exception>());
      });

      test('extiende AppException', () {
        expect(const ConnectionException(), isA<AppException>());
      });

      test('almacena uri opcional', () {
        // Arrange
        final uri = Uri.parse('https://api.example.com/products');
        final exception = ConnectionException(uri: uri);

        // Assert
        expect(exception.uri, uri);
      });

      test('almacena originalError opcional', () {
        // Arrange
        const originalError = 'Connection refused';
        const exception = ConnectionException(originalError: originalError);

        // Assert
        expect(exception.originalError, originalError);
      });

      test('toString incluye todos los campos cuando están presentes', () {
        // Arrange
        final uri = Uri.parse('https://api.example.com');
        const originalError = 'Timeout';
        const message = 'Connection failed';
        final exception = ConnectionException(
          message: message,
          uri: uri,
          originalError: originalError,
        );

        // Act
        final result = exception.toString();

        // Assert
        expect(result, contains('ConnectionException'));
        expect(result, contains(message));
        expect(result, contains(uri.toString()));
        expect(result, contains(originalError));
      });

      test('toString solo muestra ConnectionException cuando no hay datos', () {
        // Arrange
        const exception = ConnectionException();

        // Assert
        expect(exception.toString(), 'ConnectionException');
      });

      test('toString muestra mensaje cuando solo está el mensaje', () {
        // Arrange
        const exception = ConnectionException(message: 'Error');

        // Assert
        expect(exception.toString(), 'ConnectionException: Error');
      });

      test('toString muestra URI cuando solo está la URI', () {
        // Arrange
        final uri = Uri.parse('https://test.com');
        final exception = ConnectionException(uri: uri);

        // Assert
        expect(exception.toString(), contains('[URI: https://test.com]'));
      });
    });
  });
}
