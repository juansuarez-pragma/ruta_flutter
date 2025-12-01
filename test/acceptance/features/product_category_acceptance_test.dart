/// Tests de Aceptación: Productos por Categoría
///
/// FEATURE: Filtrar productos por categoría
///   Como usuario de la aplicación
///   Quiero filtrar productos por categoría
///   Para encontrar rápidamente lo que busco
///
/// CRITERIOS DE ACEPTACIÓN:
///   - AC1: El usuario puede filtrar productos por categoría
///   - AC2: Solo se muestran productos de la categoría seleccionada
///   - AC3: Se manejan categorías vacías
///   - AC4: Se pueden ver todas las categorías disponibles
///   - AC5: Los errores se muestran de forma amigable
library;

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_products_by_category_usecase.dart';

import '../../helpers/mocks.mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('Feature: Filtrar productos por categoría', () {
    late MockProductRepository mockProductRepository;
    late GetProductsByCategoryUseCase getProductsByCategoryUseCase;
    late GetAllCategoriesUseCase getCategoriesUseCase;

    setUp(() {
      mockProductRepository = MockProductRepository();
      getProductsByCategoryUseCase = GetProductsByCategoryUseCase(
        mockProductRepository,
      );
      getCategoriesUseCase = GetAllCategoriesUseCase(mockProductRepository);
    });

    group('Scenario: AC1 - Usuario filtra productos por categoría', () {
      test('Given productos en categoría "electronics", '
          'When selecciona "electronics", '
          'Then ve solo productos de electrónica', () async {
        // Given
        final electronicsProducts = [
          createTestProductEntity(
            id: 1,
            title: 'Laptop',
            category: 'electronics',
          ),
          createTestProductEntity(
            id: 2,
            title: 'Phone',
            category: 'electronics',
          ),
          createTestProductEntity(
            id: 3,
            title: 'Tablet',
            category: 'electronics',
          ),
        ];
        when(
          mockProductRepository.getProductsByCategory('electronics'),
        ).thenAnswer((_) async => Right(electronicsProducts));

        // When
        final result = await getProductsByCategoryUseCase(
          const CategoryParams(category: 'electronics'),
        );

        // Then
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('No debería fallar'), (products) {
          expect(products.length, equals(3));
          for (final product in products) {
            expect(product.category, equals('electronics'));
          }
        });
      });
    });

    group('Scenario: AC2 - Solo productos de categoría seleccionada', () {
      test('Given catálogo con múltiples categorías, '
          'When filtra por "clothing", '
          'Then solo ve productos de ropa', () async {
        // Given
        final clothingProducts = [
          createTestProductEntity(
            id: 1,
            title: 'Camiseta',
            category: 'clothing',
          ),
          createTestProductEntity(
            id: 2,
            title: 'Pantalón',
            category: 'clothing',
          ),
        ];
        when(
          mockProductRepository.getProductsByCategory('clothing'),
        ).thenAnswer((_) async => Right(clothingProducts));

        // When
        final result = await getProductsByCategoryUseCase(
          const CategoryParams(category: 'clothing'),
        );

        // Then
        result.fold((failure) => fail('No debería fallar'), (products) {
          expect(products.length, equals(2));
          expect(products.every((p) => p.category == 'clothing'), isTrue);
          expect(products.any((p) => p.category != 'clothing'), isFalse);
        });
      });
    });

    group('Scenario: AC3 - Categoría sin productos', () {
      test('Given categoría sin productos asignados, '
          'When selecciona esa categoría, '
          'Then recibe lista vacía sin errores', () async {
        // Given
        when(
          mockProductRepository.getProductsByCategory('empty-category'),
        ).thenAnswer((_) async => const Right([]));

        // When
        final result = await getProductsByCategoryUseCase(
          const CategoryParams(category: 'empty-category'),
        );

        // Then
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería fallar'),
          (products) => expect(products, isEmpty),
        );
      });
    });

    group('Scenario: AC4 - Usuario ve todas las categorías', () {
      test('Given sistema con múltiples categorías, '
          'When solicita ver categorías, '
          'Then ve lista completa de categorías', () async {
        // Given
        final availableCategories = [
          'electronics',
          'jewelery',
          "men's clothing",
          "women's clothing",
        ];
        when(
          mockProductRepository.getAllCategories(),
        ).thenAnswer((_) async => Right(availableCategories));

        // When
        final result = await getCategoriesUseCase(const NoParams());

        // Then
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('No debería fallar'), (categories) {
          expect(categories.length, equals(4));
          expect(categories, contains('electronics'));
          expect(categories, contains('jewelery'));
          expect(categories, contains("men's clothing"));
          expect(categories, contains("women's clothing"));
        });
      });
    });

    group('Scenario: AC5 - Error de conexión al filtrar', () {
      test('Given problemas de conexión, '
          'When intenta filtrar productos, '
          'Then recibe error de conexión', () async {
        // Given
        when(
          mockProductRepository.getProductsByCategory(any),
        ).thenAnswer((_) async => Left(ConnectionFailure('Error de conexión')));

        // When
        final result = await getProductsByCategoryUseCase(
          const CategoryParams(category: 'electronics'),
        );

        // Then
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Debería fallar'),
        );
      });
    });

    group('Scenario: AC6 - Error del servidor al obtener categorías', () {
      test('Given servidor con error, '
          'When intenta ver categorías, '
          'Then recibe error de servidor', () async {
        // Given
        when(
          mockProductRepository.getAllCategories(),
        ).thenAnswer((_) async => Left(ServerFailure('Error del servidor')));

        // When
        final result = await getCategoriesUseCase(const NoParams());

        // Then
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Debería fallar'),
        );
      });
    });
  });
}
