/// Tests para el método getProductsByCategory de [ProductRepositoryImpl].
///
/// ESPECIFICACIÓN: ProductRepositoryImpl.getProductsByCategory
///
/// Responsabilidad: Obtener productos por categoría y mapear excepciones a failures.
///
/// Entrada:
///   - category: String - nombre de la categoría
///
/// Salida esperada (éxito):
///   - `Either<Failure, List<ProductEntity>>`
///   - Right(lista de entidades convertidas desde modelos)
///
/// Salida esperada (error):
///   - Left(ServerFailure): DataSource lanza ServerException
///   - Left(ConnectionFailure): DataSource lanza ConnectionException
///   - Left(NotFoundFailure): DataSource lanza NotFoundException
///   - Left(ClientFailure): DataSource lanza ClientException
///
/// Precondiciones:
///   - ProductRemoteDataSource disponible e inyectado
///
/// Postcondiciones:
///   - DataSource.getByCategory() llamado exactamente 1 vez
///   - Modelos convertidos a entidades correctamente
library;

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/repositories/product_repository_impl.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late ProductRepository repository;
  late MockProductRemoteDataSource mockProductDataSource;
  late MockCategoryRemoteDataSource mockCategoryDataSource;

  setUp(() {
    mockProductDataSource = MockProductRemoteDataSource();
    mockCategoryDataSource = MockCategoryRemoteDataSource();
    repository = ProductRepositoryImpl(
      productDataSource: mockProductDataSource,
      categoryDataSource: mockCategoryDataSource,
    );
  });

  group('ProductRepositoryImpl.getProductsByCategory', () {
    const testCategory = 'electronics';

    group('cuando el datasource retorna éxito', () {
      test('retorna Right con lista de ProductEntity', () async {
        // Arrange
        final testModels = createTestProductModelList(count: 3);
        when(
          mockProductDataSource.getByCategory(testCategory),
        ).thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getProductsByCategory(testCategory);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('No debería retornar failure'), (
          entities,
        ) {
          expect(entities.length, equals(3));
          // Verificar que se convirtieron correctamente
          expect(entities[0].id, equals(testModels[0].id));
          expect(entities[0].title, equals(testModels[0].title));
        });
        verify(mockProductDataSource.getByCategory(testCategory)).called(1);
      });

      test('retorna Right con lista vacía cuando no hay productos', () async {
        // Arrange
        when(
          mockProductDataSource.getByCategory(testCategory),
        ).thenAnswer((_) async => []);

        // Act
        final result = await repository.getProductsByCategory(testCategory);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (entities) => expect(entities, isEmpty),
        );
      });
    });

    group('cuando el datasource lanza excepción', () {
      test('retorna Left ServerFailure cuando lanza ServerException', () async {
        // Arrange
        when(
          mockProductDataSource.getByCategory(testCategory),
        ).thenThrow(const ServerException());

        // Act
        final result = await repository.getProductsByCategory(testCategory);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('No debería retornar Right'),
        );
      });

      test(
        'retorna Left ConnectionFailure cuando lanza ConnectionException',
        () async {
          // Arrange
          when(mockProductDataSource.getByCategory(testCategory)).thenThrow(
            ConnectionException(uri: Uri.parse('https://api.test.com')),
          );

          // Act
          final result = await repository.getProductsByCategory(testCategory);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ConnectionFailure>()),
            (_) => fail('No debería retornar Right'),
          );
        },
      );

      test(
        'retorna Left NotFoundFailure cuando lanza NotFoundException',
        () async {
          // Arrange
          when(
            mockProductDataSource.getByCategory(testCategory),
          ).thenThrow(const NotFoundException());

          // Act
          final result = await repository.getProductsByCategory(testCategory);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<NotFoundFailure>()),
            (_) => fail('No debería retornar Right'),
          );
        },
      );

      test('retorna Left ClientFailure cuando lanza ClientException', () async {
        // Arrange
        when(
          mockProductDataSource.getByCategory(testCategory),
        ).thenThrow(const ClientException());

        // Act
        final result = await repository.getProductsByCategory(testCategory);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ClientFailure>()),
          (_) => fail('No debería retornar Right'),
        );
      });
    });
  });
}
