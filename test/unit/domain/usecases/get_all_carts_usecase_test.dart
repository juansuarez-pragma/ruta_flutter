import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_carts_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetAllCartsUseCase useCase;
  late MockCartRepository mockRepository;

  setUp(() {
    mockRepository = MockCartRepository();
    useCase = GetAllCartsUseCase(mockRepository);
  });

  group('GetAllCartsUseCase', () {
    test(
      'retorna lista de carritos cuando el repositorio tiene éxito',
      () async {
        // Arrange
        final testCarts = createTestCartEntityList(count: 3);
        when(
          mockRepository.getAllCarts(),
        ).thenAnswer((_) async => Right(testCarts));

        // Act
        final result = await useCase(const NoParams());

        // Assert
        expect(result, Right(testCarts));
        verify(mockRepository.getAllCarts()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = ServerFailure('Error del servidor');
      when(
        mockRepository.getAllCarts(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getAllCarts()).called(1);
    });

    test('retorna lista vacía cuando no hay carritos', () async {
      // Arrange
      when(
        mockRepository.getAllCarts(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('No debería retornar failure'),
        (carts) => expect(carts, isEmpty),
      );
    });
  });
}
