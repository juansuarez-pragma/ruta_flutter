import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/core/errors/exceptions.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/repositories/product_repository_impl.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late ProductRepositoryImpl repository;
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

  group('ProductRepositoryImpl', () {
    group('getAllProducts', () {
      test(
        'retorna Right con lista de productos cuando datasource tiene éxito',
        () async {
          // Arrange
          final testModels = createTestProductModelList(count: 3);
          when(
            mockProductDataSource.getAll(),
          ).thenAnswer((_) async => testModels);

          // Act
          final result = await repository.getAllProducts();

          // Assert
          expect(result.isRight(), isTrue);
          result.fold((failure) => fail('No debería retornar failure'), (
            products,
          ) {
            expect(products.length, 3);
            expect(products[0].id, testModels[0].id);
            expect(products[0].title, testModels[0].title);
          });
          verify(mockProductDataSource.getAll()).called(1);
        },
      );

      test(
        'retorna Left ServerFailure cuando datasource lanza ServerException',
        () async {
          // Arrange
          when(mockProductDataSource.getAll()).thenThrow(ServerException());

          // Act
          final result = await repository.getAllProducts();

          // Assert
          expect(result, Left(ServerFailure(AppStrings.serverFailureMessage)));
        },
      );

      test(
        'retorna Left ConnectionFailure cuando datasource lanza ConnectionException',
        () async {
          // Arrange
          when(mockProductDataSource.getAll()).thenThrow(
            ConnectionException(
              uri: Uri.parse('https://api.test.com'),
              originalError: 'Connection refused',
            ),
          );

          // Act
          final result = await repository.getAllProducts();

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<ConnectionFailure>()),
            (_) => fail('No debería retornar Right'),
          );
        },
      );

      test('convierte modelos a entidades correctamente', () async {
        // Arrange
        final testModels = [
          createTestProductModel(id: 1, title: 'Producto 1', price: 10.0),
          createTestProductModel(id: 2, title: 'Producto 2', price: 20.0),
        ];
        when(
          mockProductDataSource.getAll(),
        ).thenAnswer((_) async => testModels);

        // Act
        final result = await repository.getAllProducts();

        // Assert
        result.fold((failure) => fail('No debería retornar failure'), (
          products,
        ) {
          for (var i = 0; i < products.length; i++) {
            expect(products[i].id, testModels[i].id);
            expect(products[i].title, testModels[i].title);
            expect(products[i].price, testModels[i].price);
          }
        });
      });
    });

    group('getProductById', () {
      const testId = 1;

      test(
        'retorna Right con producto cuando datasource tiene éxito',
        () async {
          // Arrange
          final testModel = createTestProductModel(id: testId);
          when(
            mockProductDataSource.getById(testId),
          ).thenAnswer((_) async => testModel);

          // Act
          final result = await repository.getProductById(testId);

          // Assert
          expect(result.isRight(), isTrue);
          result.fold((failure) => fail('No debería retornar failure'), (
            product,
          ) {
            expect(product.id, testId);
            expect(product.title, testModel.title);
          });
          verify(mockProductDataSource.getById(testId)).called(1);
        },
      );

      test(
        'retorna Left NotFoundFailure cuando datasource lanza NotFoundException',
        () async {
          // Arrange
          when(
            mockProductDataSource.getById(testId),
          ).thenThrow(NotFoundException());

          // Act
          final result = await repository.getProductById(testId);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<NotFoundFailure>());
            expect(failure.message, AppStrings.notFoundProductFailureMessage);
          }, (_) => fail('No debería retornar Right'));
        },
      );

      test(
        'retorna Left ServerFailure cuando datasource lanza ServerException',
        () async {
          // Arrange
          when(
            mockProductDataSource.getById(testId),
          ).thenThrow(ServerException());

          // Act
          final result = await repository.getProductById(testId);

          // Assert
          expect(result, Left(ServerFailure(AppStrings.serverFailureMessage)));
        },
      );

      test('pasa el ID correcto al datasource', () async {
        // Arrange
        const specificId = 42;
        final testModel = createTestProductModel(id: specificId);
        when(
          mockProductDataSource.getById(specificId),
        ).thenAnswer((_) async => testModel);

        // Act
        await repository.getProductById(specificId);

        // Assert
        verify(mockProductDataSource.getById(specificId)).called(1);
      });
    });

    group('getAllCategories', () {
      test(
        'retorna Right con lista de categorías cuando datasource tiene éxito',
        () async {
          // Arrange
          final testCategories = createTestCategories();
          when(
            mockCategoryDataSource.getAll(),
          ).thenAnswer((_) async => testCategories);

          // Act
          final result = await repository.getAllCategories();

          // Assert
          expect(result, Right(testCategories));
          verify(mockCategoryDataSource.getAll()).called(1);
        },
      );

      test(
        'retorna Left ServerFailure cuando datasource lanza ServerException',
        () async {
          // Arrange
          when(mockCategoryDataSource.getAll()).thenThrow(ServerException());

          // Act
          final result = await repository.getAllCategories();

          // Assert
          expect(result, Left(ServerFailure(AppStrings.serverFailureMessage)));
        },
      );

      test(
        'retorna Left NotFoundFailure con mensaje personalizado cuando datasource lanza NotFoundException',
        () async {
          // Arrange
          when(mockCategoryDataSource.getAll()).thenThrow(NotFoundException());

          // Act
          final result = await repository.getAllCategories();

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold((failure) {
            expect(failure, isA<NotFoundFailure>());
            expect(
              failure.message,
              AppStrings.notFoundCategoriesFailureMessage,
            );
          }, (_) => fail('No debería retornar Right'));
        },
      );

      test('retorna lista vacía cuando no hay categorías', () async {
        // Arrange
        when(
          mockCategoryDataSource.getAll(),
        ).thenAnswer((_) async => <String>[]);

        // Act
        final result = await repository.getAllCategories();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería retornar failure'),
          (categories) => expect(categories, isEmpty),
        );
      });
    });
  });
}
