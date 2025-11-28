import 'package:dartz/dartz.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/repositories/base/base_repository.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

/// Implementación concreta de BaseRepository para testing.
class TestableBaseRepository extends BaseRepository {
  Future<Either<Failure, T>> executeRequest<T>(
    Future<T> Function() action, {
    String notFoundMessage = AppStrings.notFoundFailureMessage,
  }) {
    return handleRequest(action, notFoundMessage: notFoundMessage);
  }
}

void main() {
  late TestableBaseRepository repository;

  setUp(() {
    repository = TestableBaseRepository();
  });

  group('BaseRepository.handleRequest', () {
    test('retorna Right con resultado cuando la acción tiene éxito', () async {
      // Arrange
      const expectedResult = 'success';

      // Act
      final result = await repository.executeRequest(() async => expectedResult);

      // Assert
      expect(result, const Right(expectedResult));
    });

    test('retorna Left ServerFailure cuando se lanza ServerException', () async {
      // Act
      final result = await repository.executeRequest<String>(
        () async => throw ServerException(),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, AppStrings.serverFailureMessage);
        },
        (_) => fail('No debería retornar Right'),
      );
    });

    test('retorna Left NotFoundFailure cuando se lanza NotFoundException', () async {
      // Act
      final result = await repository.executeRequest<String>(
        () async => throw NotFoundException(),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, AppStrings.notFoundFailureMessage);
        },
        (_) => fail('No debería retornar Right'),
      );
    });

    test('usa mensaje personalizado para NotFoundFailure', () async {
      // Arrange
      const customMessage = 'Producto específico no encontrado';

      // Act
      final result = await repository.executeRequest<String>(
        () async => throw NotFoundException(),
        notFoundMessage: customMessage,
      );

      // Assert
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, customMessage);
        },
        (_) => fail('No debería retornar Right'),
      );
    });

    test('retorna Left ClientFailure cuando se lanza ClientException', () async {
      // Act
      final result = await repository.executeRequest<String>(
        () async => throw ClientException(),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ClientFailure>());
          expect(failure.message, AppStrings.clientFailureMessage);
        },
        (_) => fail('No debería retornar Right'),
      );
    });

    test('retorna Left ConnectionFailure cuando se lanza ConnectionException', () async {
      // Act
      final result = await repository.executeRequest<String>(
        () async => throw ConnectionException(
          uri: Uri.parse('https://api.test.com'),
          originalError: 'Connection refused',
        ),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ConnectionFailure>());
          expect(failure.message, AppStrings.connectionFailureMessage);
        },
        (_) => fail('No debería retornar Right'),
      );
    });

    test('retorna Left ServerFailure para excepciones desconocidas', () async {
      // Act
      final result = await repository.executeRequest<String>(
        () async => throw Exception('Error inesperado'),
      );

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            failure.message,
            contains(AppStrings.unexpectedFailureMessage),
          );
        },
        (_) => fail('No debería retornar Right'),
      );
    });

    test('maneja valores de retorno complejos', () async {
      // Arrange
      final expectedList = [1, 2, 3, 4, 5];

      // Act
      final result = await repository.executeRequest(() async => expectedList);

      // Assert
      expect(result, Right(expectedList));
    });

    test('maneja valores nulos como resultado válido', () async {
      // Act
      final result = await repository.executeRequest<String?>(() async => null);

      // Assert
      expect(result, const Right(null));
    });
  });
}
