import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('almacena el mensaje correctamente', () {
        // Arrange
        const message = 'Error del servidor';

        // Act
        const failure = ServerFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('extiende Failure', () {
        // Arrange & Act
        const failure = ServerFailure('test');

        // Assert
        expect(failure, isA<Failure>());
      });

      test('props contiene el mensaje', () {
        // Arrange
        const message = 'Error message';
        const failure = ServerFailure(message);

        // Assert
        expect(failure.props, [message]);
      });

      test('dos failures con mismo mensaje son iguales', () {
        // Arrange
        const failure1 = ServerFailure('Error');
        const failure2 = ServerFailure('Error');

        // Assert
        expect(failure1, equals(failure2));
      });

      test('dos failures con diferente mensaje no son iguales', () {
        // Arrange
        const failure1 = ServerFailure('Error 1');
        const failure2 = ServerFailure('Error 2');

        // Assert
        expect(failure1, isNot(equals(failure2)));
      });
    });

    group('NotFoundFailure', () {
      test('almacena el mensaje correctamente', () {
        // Arrange
        const message = 'Recurso no encontrado';

        // Act
        const failure = NotFoundFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('extiende Failure', () {
        // Arrange & Act
        const failure = NotFoundFailure('test');

        // Assert
        expect(failure, isA<Failure>());
      });

      test('props contiene el mensaje', () {
        // Arrange
        const message = 'Not found';
        const failure = NotFoundFailure(message);

        // Assert
        expect(failure.props, [message]);
      });
    });

    group('ClientFailure', () {
      test('almacena el mensaje correctamente', () {
        // Arrange
        const message = 'Error del cliente';

        // Act
        const failure = ClientFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('extiende Failure', () {
        // Arrange & Act
        const failure = ClientFailure('test');

        // Assert
        expect(failure, isA<Failure>());
      });

      test('props contiene el mensaje', () {
        // Arrange
        const message = 'Client error';
        const failure = ClientFailure(message);

        // Assert
        expect(failure.props, [message]);
      });
    });

    group('ConnectionFailure', () {
      test('almacena el mensaje correctamente', () {
        // Arrange
        const message = 'Error de conexión';

        // Act
        const failure = ConnectionFailure(message);

        // Assert
        expect(failure.message, message);
      });

      test('extiende Failure', () {
        // Arrange & Act
        const failure = ConnectionFailure('test');

        // Assert
        expect(failure, isA<Failure>());
      });

      test('props contiene el mensaje', () {
        // Arrange
        const message = 'Connection error';
        const failure = ConnectionFailure(message);

        // Assert
        expect(failure.props, [message]);
      });
    });

    group('igualdad entre diferentes tipos de Failure', () {
      test(
        'ServerFailure y NotFoundFailure con mismo mensaje no son iguales',
        () {
          // Arrange
          const serverFailure = ServerFailure('Error');
          const notFoundFailure = NotFoundFailure('Error');

          // Assert
          expect(serverFailure, isNot(equals(notFoundFailure)));
        },
      );

      test(
        'ClientFailure y ConnectionFailure con mismo mensaje no son iguales',
        () {
          // Arrange
          const clientFailure = ClientFailure('Error');
          const connectionFailure = ConnectionFailure('Error');

          // Assert
          expect(clientFailure, isNot(equals(connectionFailure)));
        },
      );
    });
  });
}
