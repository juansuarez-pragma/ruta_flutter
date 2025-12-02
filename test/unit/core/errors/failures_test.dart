import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';

void main() {
  group('Failure', () {
    group('ServerFailure', () {
      test('almacena el mensaje correctamente', () {
        const failure = ServerFailure('Error del servidor');
        expect(failure.message, 'Error del servidor');
      });

      test('dos failures con mismo mensaje son iguales (Equatable)', () {
        const failure1 = ServerFailure('Error');
        const failure2 = ServerFailure('Error');
        expect(failure1, equals(failure2));
      });
    });

    group('NotFoundFailure', () {
      test('almacena el mensaje correctamente', () {
        const failure = NotFoundFailure('Recurso no encontrado');
        expect(failure.message, 'Recurso no encontrado');
      });
    });

    group('ClientFailure', () {
      test('almacena el mensaje correctamente', () {
        const failure = ClientFailure('Error del cliente');
        expect(failure.message, 'Error del cliente');
      });
    });

    group('ConnectionFailure', () {
      test('almacena el mensaje correctamente', () {
        const failure = ConnectionFailure('Error de conexión');
        expect(failure.message, 'Error de conexión');
      });
    });

    group('igualdad entre tipos', () {
      test('diferentes tipos de Failure con mismo mensaje no son iguales', () {
        const serverFailure = ServerFailure('Error');
        const notFoundFailure = NotFoundFailure('Error');
        expect(serverFailure, isNot(equals(notFoundFailure)));
      });
    });
  });
}
