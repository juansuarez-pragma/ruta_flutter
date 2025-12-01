import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetAllCategoriesUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetAllCategoriesUseCase(mockRepository);
  });

  group('GetAllCategoriesUseCase', () {
    test(
      'retorna lista de categorías cuando el repositorio tiene éxito',
      () async {
        // Arrange
        final testCategories = createTestCategories();
        when(
          mockRepository.getAllCategories(),
        ).thenAnswer((_) async => Right(testCategories));

        // Act
        final result = await useCase(const NoParams());

        // Assert
        expect(result, Right(testCategories));
        verify(mockRepository.getAllCategories()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = ServerFailure('Error del servidor');
      when(
        mockRepository.getAllCategories(),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getAllCategories()).called(1);
    });

    test('retorna lista vacía cuando no hay categorías', () async {
      // Arrange
      when(
        mockRepository.getAllCategories(),
      ).thenAnswer((_) async => const Right(<String>[]));

      // Act
      final result = await useCase(const NoParams());

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('No debería retornar failure'),
        (categories) => expect(categories, isEmpty),
      );
    });
  });
}
