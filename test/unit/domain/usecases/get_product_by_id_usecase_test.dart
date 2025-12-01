import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetProductByIdUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductByIdUseCase(mockRepository);
  });

  group('GetProductByIdUseCase', () {
    const testId = 1;
    const params = GetProductByIdParams(id: testId);

    test('retorna producto cuando el repositorio tiene éxito', () async {
      // Arrange
      final testProduct = createTestProductEntity(id: testId);
      when(
        mockRepository.getProductById(testId),
      ).thenAnswer((_) async => Right(testProduct));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Right(testProduct));
      verify(mockRepository.getProductById(testId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('retorna Failure cuando el repositorio falla', () async {
      // Arrange
      final failure = NotFoundFailure('Producto no encontrado');
      when(
        mockRepository.getProductById(testId),
      ).thenAnswer((_) async => Left(failure));

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, Left(failure));
      verify(mockRepository.getProductById(testId)).called(1);
    });

    test('pasa el ID correcto al repositorio', () async {
      // Arrange
      const specificId = 42;
      const specificParams = GetProductByIdParams(id: specificId);
      final testProduct = createTestProductEntity(id: specificId);
      when(
        mockRepository.getProductById(specificId),
      ).thenAnswer((_) async => Right(testProduct));

      // Act
      await useCase(specificParams);

      // Assert
      verify(mockRepository.getProductById(specificId)).called(1);
    });
  });

  group('GetProductByIdParams', () {
    test('dos params con mismo id son iguales', () {
      // Arrange
      const params1 = GetProductByIdParams(id: 1);
      const params2 = GetProductByIdParams(id: 1);

      // Assert
      expect(params1, equals(params2));
    });

    test('dos params con diferente id no son iguales', () {
      // Arrange
      const params1 = GetProductByIdParams(id: 1);
      const params2 = GetProductByIdParams(id: 2);

      // Assert
      expect(params1, isNot(equals(params2)));
    });

    test('props contiene el id', () {
      // Arrange
      const params = GetProductByIdParams(id: 5);

      // Assert
      expect(params.props, [5]);
    });
  });
}
