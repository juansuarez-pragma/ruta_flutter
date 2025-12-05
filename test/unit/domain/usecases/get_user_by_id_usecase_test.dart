import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_user_by_id_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetUserByIdUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserByIdUseCase(mockRepository);
  });

  group('GetUserByIdUseCase', () {
    const testId = 1;
    const params = GetUserByIdParams(id: testId);

    test('retorna usuario cuando el repositorio tiene éxito', () async {
      // Arrange
      final testUser = createTestUserEntity(id: testId);
      when(
        mockRepository.getUserById(testId),
      ).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Right(testUser));
      verify(mockRepository.getUserById(testId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = NotFoundFailure('Usuario no encontrado');
      when(
        mockRepository.getUserById(testId),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getUserById(testId)).called(1);
    });

    test('pasa el ID correcto al repositorio', () async {
      // Arrange
      const specificId = 42;
      const specificParams = GetUserByIdParams(id: specificId);
      final testUser = createTestUserEntity(id: specificId);
      when(
        mockRepository.getUserById(specificId),
      ).thenAnswer((_) async => Right(testUser));

      // Act
      await useCase(specificParams);

      // Assert
      verify(mockRepository.getUserById(specificId)).called(1);
    });

    test('retorna NotFoundFailure cuando usuario no existe', () async {
      // Arrange
      const invalidId = 999;
      const invalidParams = GetUserByIdParams(id: invalidId);
      final failure = NotFoundFailure('Usuario no encontrado');
      when(
        mockRepository.getUserById(invalidId),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(invalidParams);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('No debería retornar éxito'),
      );
    });
  });

  group('GetUserByIdParams', () {
    test('dos params con mismo id son iguales', () {
      // Arrange
      const params1 = GetUserByIdParams(id: 1);
      const params2 = GetUserByIdParams(id: 1);

      // Assert
      expect(params1, equals(params2));
    });

    test('dos params con diferente id no son iguales', () {
      // Arrange
      const params1 = GetUserByIdParams(id: 1);
      const params2 = GetUserByIdParams(id: 2);

      // Assert
      expect(params1, isNot(equals(params2)));
    });

    test('props contiene el id', () {
      // Arrange
      const params = GetUserByIdParams(id: 5);

      // Assert
      expect(params.props, [5]);
    });
  });
}
