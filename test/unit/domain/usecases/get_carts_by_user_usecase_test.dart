import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_carts_by_user_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetCartsByUserUseCase useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = GetCartsByUserUseCase(mockRepository);
  });

  group('GetCartsByUserUseCase', () {
    const testUserId = 1;

    test(
      'retorna lista de carritos del usuario cuando el repositorio tiene éxito',
      () async {
        // Arrange
        final testCarts = createTestCartEntityList(count: 2);
        when(
          mockRepository.getCartsByUser(testUserId),
        ).thenAnswer((_) async => Right(testCarts));

        // Act
        final result = await useCase(
          const GetCartsByUserParams(userId: testUserId),
        );

        // Assert
        expect(result, Right(testCarts));
        verify(mockRepository.getCartsByUser(testUserId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = ServerFailure('Error del servidor');
      when(
        mockRepository.getCartsByUser(testUserId),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(
        const GetCartsByUserParams(userId: testUserId),
      );

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getCartsByUser(testUserId)).called(1);
    });

    test('retorna lista vacía cuando el usuario no tiene carritos', () async {
      // Arrange
      when(
        mockRepository.getCartsByUser(testUserId),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(
        const GetCartsByUserParams(userId: testUserId),
      );

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('No debería retornar failure'),
        (carts) => expect(carts, isEmpty),
      );
    });
  });

  group('GetCartsByUserParams', () {
    test('dos instancias con mismo userId son iguales', () {
      // Arrange & Act
      const params1 = GetCartsByUserParams(userId: 1);
      const params2 = GetCartsByUserParams(userId: 1);

      // Assert
      expect(params1, equals(params2));
    });

    test('dos instancias con diferente userId no son iguales', () {
      // Arrange & Act
      const params1 = GetCartsByUserParams(userId: 1);
      const params2 = GetCartsByUserParams(userId: 2);

      // Assert
      expect(params1, isNot(equals(params2)));
    });

    test('props contiene el userId', () {
      // Arrange
      const params = GetCartsByUserParams(userId: 1);

      // Assert
      expect(params.props, equals([1]));
    });
  });
}
