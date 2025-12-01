/// Tests de Aceptación: Detalle de Producto
///
/// FEATURE: Ver detalle de producto
///   Como usuario de la aplicación
///   Quiero ver el detalle completo de un producto
///   Para tomar una decisión de compra informada
///
/// CRITERIOS DE ACEPTACIÓN:
///   - AC1: El usuario puede ver el detalle de un producto por ID
///   - AC2: El detalle incluye toda la información del producto
///   - AC3: Se valida que el ID sea un número positivo
///   - AC4: Se maneja correctamente cuando el producto no existe
///   - AC5: Se muestran errores de forma amigable
library;

import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';

import '../../helpers/mocks.mocks.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('Feature: Ver detalle de producto', () {
    late MockProductRepository mockRepository;
    late GetProductByIdUseCase useCase;

    setUp(() {
      mockRepository = MockProductRepository();
      useCase = GetProductByIdUseCase(mockRepository);
    });

    group('Scenario: AC1 - Usuario ve detalle de producto existente', () {
      test('Given producto con ID 42 en catálogo, '
          'When solicita ver producto 42, '
          'Then recibe detalle completo', () async {
        // Given
        final productDetail = createTestProductEntity(
          id: 42,
          title: 'Smartphone Premium',
          price: 899.99,
          description: 'Último modelo con cámara de 108MP',
          category: 'electronics',
          image: 'https://example.com/phone.jpg',
        );
        when(
          mockRepository.getProductById(42),
        ).thenAnswer((_) async => Right(productDetail));

        // When
        final result = await useCase(const GetProductByIdParams(id: 42));

        // Then
        expect(result.isRight(), isTrue);
        result.fold((failure) => fail('No debería fallar'), (product) {
          expect(product.id, equals(42));
          expect(product.title, equals('Smartphone Premium'));
        });
        verify(mockRepository.getProductById(42)).called(1);
      });
    });

    group('Scenario: AC2 - Detalle incluye toda la información', () {
      test('Given producto completo en sistema, '
          'When consulta detalle, '
          'Then ve título, precio, descripción, categoría e imagen', () async {
        // Given
        final fullProduct = createTestProductEntity(
          id: 1,
          title: 'Auriculares Bluetooth',
          price: 149.99,
          description: 'Auriculares inalámbricos con cancelación de ruido',
          category: 'electronics',
          image: 'https://example.com/headphones.jpg',
        );
        when(
          mockRepository.getProductById(1),
        ).thenAnswer((_) async => Right(fullProduct));

        // When
        final result = await useCase(const GetProductByIdParams(id: 1));

        // Then
        result.fold((failure) => fail('No debería fallar'), (product) {
          expect(product.title, equals('Auriculares Bluetooth'));
          expect(product.price, equals(149.99));
          expect(
            product.description,
            equals('Auriculares inalámbricos con cancelación de ruido'),
          );
          expect(product.category, equals('electronics'));
          expect(product.image, equals('https://example.com/headphones.jpg'));
        });
      });
    });

    group('Scenario: AC3 - Validación de ID de producto', () {
      test('Given ID de producto válido, '
          'When solicita producto con ID positivo, '
          'Then la solicitud se procesa correctamente', () async {
        // Given
        when(
          mockRepository.getProductById(any),
        ).thenAnswer((_) async => Right(createTestProductEntity()));

        // When
        final result = await useCase(const GetProductByIdParams(id: 1));

        // Then
        expect(result.isRight(), isTrue);
      });
    });

    group('Scenario: AC4 - Producto no encontrado', () {
      test('Given no existe producto con ID 9999, '
          'When busca producto 9999, '
          'Then recibe mensaje de no encontrado', () async {
        // Given
        when(mockRepository.getProductById(9999)).thenAnswer(
          (_) async => Left(NotFoundFailure('Producto no encontrado')),
        );

        // When
        final result = await useCase(const GetProductByIdParams(id: 9999));

        // Then
        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, contains('no encontrado'));
        }, (_) => fail('Debería fallar'));
      });
    });

    group('Scenario: AC5 - Error de conexión al buscar producto', () {
      test('Given problemas de conectividad, '
          'When intenta ver producto, '
          'Then recibe error de conexión', () async {
        // Given
        when(mockRepository.getProductById(any)).thenAnswer(
          (_) async => Left(ConnectionFailure('Sin conexión a internet')),
        );

        // When
        final result = await useCase(const GetProductByIdParams(id: 1));

        // Then
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ConnectionFailure>()),
          (_) => fail('Debería fallar'),
        );
      });
    });

    group('Scenario: AC6 - Error del servidor al buscar producto', () {
      test('Given servidor con error interno, '
          'When intenta ver producto, '
          'Then recibe error de servidor', () async {
        // Given
        when(mockRepository.getProductById(any)).thenAnswer(
          (_) async => Left(ServerFailure('Error 500: Internal Server Error')),
        );

        // When
        final result = await useCase(const GetProductByIdParams(id: 1));

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
