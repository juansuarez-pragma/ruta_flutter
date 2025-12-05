import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_users_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetAllUsersUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetAllUsersUseCase(mockRepository);
  });

  group('GetAllUsersUseCase', () {
    test(
      'retorna lista de usuarios cuando el repositorio tiene éxito',
      () async {
        // Arrange
        final testUsers = createTestUserEntityList(count: 3);
        when(
          mockRepository.getAllUsers(),
        ).thenAnswer((_) async => Right(testUsers));

        // Act
        final result = await useCase(const NoParams());

        // Assert
        expect(result, Right(testUsers));
        verify(mockRepository.getAllUsers()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = ServerFailure('Error del servidor');
      when(
        mockRepository.getAllUsers(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getAllUsers()).called(1);
    });

    test('retorna lista vacía cuando no hay usuarios', () async {
      // Arrange
      when(
        mockRepository.getAllUsers(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('No debería retornar failure'),
        (users) => expect(users, isEmpty),
      );
    });

    test('retorna ConnectionFailure cuando no hay conexión', () async {
      // Arrange
      final failure = ConnectionFailure('Sin conexión a internet');
      when(
        mockRepository.getAllUsers(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<ConnectionFailure>()),
        (_) => fail('No debería retornar éxito'),
      );
    });
  });
}
