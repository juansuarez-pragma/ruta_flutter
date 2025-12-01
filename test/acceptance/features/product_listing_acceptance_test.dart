/// Tests de Aceptación: Listado de Productos
///
/// FEATURE: Listado de productos
///   Como usuario de la aplicación
///   Quiero ver una lista de productos disponibles
///   Para poder explorar el catálogo de la tienda
///
/// CRITERIOS DE ACEPTACIÓN:
///   - AC1: El usuario puede ver todos los productos
///   - AC2: Cada producto muestra id, título, precio, categoría
///   - AC3: Los precios se muestran en formato monetario válido
///   - AC4: Se maneja correctamente cuando no hay productos
///   - AC5: Se muestran errores de conexión de forma amigable
library;

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';

import '../../helpers/mocks.mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('Feature: Listado de productos', () {
    late MockProductRepository mockRepository;
    late GetAllProductsUseCase useCase;

    setUp(() {
      mockRepository = MockProductRepository();
      useCase = GetAllProductsUseCase(mockRepository);
    });

    group('Scenario: AC1 - Usuario ve todos los productos disponibles', () {
      test('Given catálogo con productos, '
          'When solicita ver todos, '
          'Then recibe lista completa', () async {
        // Given: Configurar repositorio con productos
        final productList = createTestProductEntityList(count: 5);
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => Right(productList));

        // When: Ejecutar caso de uso
        final result = await useCase(const NoParams());

        // Then: Verificar resultado
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('No debería fallar'), (products) {
          expect(products.length, equals(5));
          for (final product in products) {
            expect(product.id, isPositive);
            expect(product.title, isNotEmpty);
            expect(product.price, isNonNegative);
            expect(product.category, isNotEmpty);
          }
        });
        verify(mockRepository.getAllProducts()).called(1);
      });
    });

    group('Scenario: AC2 - Productos muestran información completa', () {
      test(
        'Given producto con todos sus atributos, '
        'When consulta productos, '
        'Then ve id, título, precio, categoría, descripción e imagen',
        () async {
          // Given
          final product = createTestProductEntity(
            id: 42,
            title: 'Laptop Gaming Pro',
            price: 1299.99,
            description: 'Laptop de alto rendimiento para gaming',
            category: 'electronics',
            image: 'https://example.com/laptop.jpg',
          );
          when(
            mockRepository.getAllProducts(),
          ).thenAnswer((_) async => Right([product]));

          // When
          final result = await useCase(const NoParams());

          // Then
          result.fold((failure) => fail('No debería fallar'), (products) {
            final p = products.first;
            expect(p.id, equals(42));
            expect(p.title, equals('Laptop Gaming Pro'));
            expect(p.price, equals(1299.99));
            expect(
              p.description,
              equals('Laptop de alto rendimiento para gaming'),
            );
            expect(p.category, equals('electronics'));
            expect(p.image, equals('https://example.com/laptop.jpg'));
          });
        },
      );
    });

    group('Scenario: AC3 - Precios son valores válidos', () {
      test('Given productos con diferentes precios, '
          'When consulta productos, '
          'Then todos los precios son no negativos', () async {
        // Given
        final products = [
          createTestProductEntity(id: 1, price: 0.01),
          createTestProductEntity(id: 2, price: 99.99),
          createTestProductEntity(id: 3, price: 9999.99),
        ];
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => Right(products));

        // When
        final result = await useCase(const NoParams());

        // Then
        result.fold((failure) => fail('No debería fallar'), (products) {
          for (final product in products) {
            expect(product.price, isNonNegative);
            expect(product.price, isA<double>());
          }
        });
      });
    });

    group('Scenario: AC4 - Catálogo vacío se maneja correctamente', () {
      test('Given catálogo sin productos, '
          'When solicita ver productos, '
          'Then recibe lista vacía sin errores', () async {
        // Given
        when(
          mockRepository.getAllProducts(),
        ).thenAnswer((_) async => const Right([]));

        // When
        final result = await useCase(const NoParams());

        // Then
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('No debería fallar'),
          (products) => expect(products, isEmpty),
        );
      });
    });

    group('Scenario: AC5 - Error de conexión se maneja correctamente', () {
      test('Given problema de conexión, '
          'When intenta ver productos, '
          'Then recibe error de conexión descriptivo', () async {
        // Given
        when(mockRepository.getAllProducts()).thenAnswer(
          (_) async =>
              Left(ConnectionFailure('No se pudo conectar al servidor')),
        );

        // When
        final result = await useCase(const NoParams());

        // Then
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<ConnectionFailure>());
          expect(failure.message, contains('conectar'));
        }, (_) => fail('Debería fallar'));
      });
    });

    group('Scenario: AC6 - Error del servidor se maneja correctamente', () {
      test('Given servidor con error interno, '
          'When intenta ver productos, '
          'Then recibe error de servidor', () async {
        // Given
        when(mockRepository.getAllProducts()).thenAnswer(
          (_) async => Left(ServerFailure('Error interno del servidor')),
        );

        // When
        final result = await useCase(const NoParams());

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
