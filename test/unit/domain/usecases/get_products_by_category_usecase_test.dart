/// Tests para [GetProductsByCategoryUseCase].
///
/// ESPECIFICACIÓN: GetProductsByCategoryUseCase
///
/// Responsabilidad: Obtener productos filtrados por una categoría específica.
///
/// Entrada:
///   - params: CategoryParams
///     - category: String - nombre de la categoría (no vacío)
///
/// Salida esperada (éxito):
///   - `Either<Failure, List<ProductEntity>>`
///   - Right(lista de productos de esa categoría)
///   - Lista puede estar vacía si no hay productos en la categoría
///
/// Salida esperada (error):
///   - Left(ServerFailure): API retorna código 5xx
///   - Left(ConnectionFailure): Error de red/timeout
///   - Left(NotFoundFailure): Categoría no existe (404)
///   - Left(ClientFailure): Otros errores 4xx
///
/// Precondiciones:
///   - Repository disponible e inyectado
///   - Categoría es un string no vacío
///
/// Postcondiciones:
///   - Repository.getProductsByCategory() llamado exactamente 1 vez
///   - Sin efectos secundarios
library;

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_products_by_category_usecase.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late GetProductsByCategoryUseCase useCase;
  late MockProductRepository mockRepository;

  setUp(() {
    mockRepository = MockProductRepository();
    useCase = GetProductsByCategoryUseCase(mockRepository);
  });

  group('GetProductsByCategoryUseCase', () {
    const testCategory = 'electronics';

    group('cuando el repositorio retorna éxito', () {
      test('retorna lista de productos de la categoría especificada', () async {
        // Arrange
        final testProducts = createTestProductEntityList(count: 3).map((p) {
          return ProductEntity(
            id: p.id,
            title: p.title,
            price: p.price,
            description: p.description,
            category: testCategory,
            image: p.image,
          );
        }).toList();

        when(
          mockRepository.getProductsByCategory(testCategory),
        ).thenAnswer((_) async => Right(testProducts));

        // Act
        final result = await useCase(
          const CategoryParams(category: testCategory),
        );

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('No debería retornar failure'), (
          products,
        ) {
          expect(products.length, equals(3));
          expect(products.every((p) => p.category == testCategory), isTrue);
        });
        verify(mockRepository.getProductsByCategory(testCategory)).called(1);
        verifyNoMoreInteractions(mockRepository);
      });

      test(
        'retorna lista vacía cuando no hay productos en la categoría',
        () async {
          // Arrange
          when(
            mockRepository.getProductsByCategory(testCategory),
          ).thenAnswer((_) async => const Right([]));

          // Act
          final result = await useCase(
            const CategoryParams(category: testCategory),
          );

          // Assert
          expect(result.isRight(), isTrue);
          result.fold(
            (failure) => fail('No debería retornar failure'),
            (products) => expect(products, isEmpty),
          );
        },
      );
    });

    group('cuando el repositorio retorna error', () {
      test('retorna ServerFailure cuando el servidor falla', () async {
        // Arrange
        const failure = ServerFailure('Error interno del servidor');
        when(
          mockRepository.getProductsByCategory(testCategory),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          const CategoryParams(category: testCategory),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<ServerFailure>()),
          (_) => fail('No debería retornar Right'),
        );
      });

      test('retorna ConnectionFailure cuando hay error de conexión', () async {
        // Arrange
        const failure = ConnectionFailure('Sin conexión a internet');
        when(
          mockRepository.getProductsByCategory(testCategory),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          const CategoryParams(category: testCategory),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<ConnectionFailure>()),
          (_) => fail('No debería retornar Right'),
        );
      });

      test('retorna NotFoundFailure cuando la categoría no existe', () async {
        // Arrange
        const failure = NotFoundFailure('Categoría no encontrada');
        when(
          mockRepository.getProductsByCategory('categoria_invalida'),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          const CategoryParams(category: 'categoria_invalida'),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<NotFoundFailure>()),
          (_) => fail('No debería retornar Right'),
        );
      });

      test('retorna ClientFailure para otros errores del cliente', () async {
        // Arrange
        const failure = ClientFailure('Error en la petición');
        when(
          mockRepository.getProductsByCategory(testCategory),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(
          const CategoryParams(category: testCategory),
        );

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f, isA<ClientFailure>()),
          (_) => fail('No debería retornar Right'),
        );
      });
    });

    group('CategoryParams', () {
      test('dos params con misma categoría son iguales (Equatable)', () {
        // Arrange & Act
        const params1 = CategoryParams(category: 'electronics');
        const params2 = CategoryParams(category: 'electronics');

        // Assert
        expect(params1, equals(params2));
        expect(params1.hashCode, equals(params2.hashCode));
      });

      test('dos params con diferente categoría no son iguales', () {
        // Arrange & Act
        const params1 = CategoryParams(category: 'electronics');
        const params2 = CategoryParams(category: 'jewelery');

        // Assert
        expect(params1, isNot(equals(params2)));
      });

      test('props contiene la categoría', () {
        // Arrange & Act
        const params = CategoryParams(category: 'electronics');

        // Assert
        expect(params.props, contains('electronics'));
      });
    });
  });
}
