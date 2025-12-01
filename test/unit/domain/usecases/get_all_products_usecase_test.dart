import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetAllProductsUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetAllProductsUseCase(mockRepository);
  });

  group('GetAllProductsUseCase', () {
    test(
      'retorna lista de productos cuando el repositorio tiene éxito',
      () async {
        // Arrange
        final testProducts = createTestProductEntityList(count: 3);
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(const NoParams());

        // Assert
        expect(result, Right(testProducts));
        verify(mockRepository.getAllProducts()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = ServerFailure('Error del servidor');
      when(
        mockRepository.getAllProducts(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getAllProducts()).called(1);
    });

    test('retorna lista vacía cuando no hay productos', () async {
      // Arrange
      when(
        mockRepository.getAllProducts(),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('No debería retornar failure'),
        (products) => expect(products, isEmpty),
      );
    });
  });
}
