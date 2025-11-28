import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/data/models/product_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

import '../../../fixtures/product_fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  group('ProductModel', () {
    group('fromJson', () {
      test('crea modelo desde JSON válido', () {
        // Act
        final model = ProductModel.fromJson(validProductJson);

        // Assert
        expect(model.id, 1);
        expect(model.title, 'Producto de prueba');
        expect(model.price, 99.99);
        expect(model.description, 'Descripción del producto de prueba');
        expect(model.category, 'electronics');
        expect(model.image, 'https://example.com/image.jpg');
      });

      test('convierte precio numérico entero a double', () {
        // Act
        final model = ProductModel.fromJson(productJsonWithIntPrice);

        // Assert
        expect(model.price, isA<double>());
        expect(model.price, 100.0);
      });

      test('lanza excepción cuando falta campo requerido', () {
        // Assert
        expect(
          () => ProductModel.fromJson(incompleteProductJson),
          throwsA(isA<TypeError>()),
        );
      });

      test('lanza excepción cuando el tipo es incorrecto', () {
        // Assert
        expect(
          () => ProductModel.fromJson(wrongTypeProductJson),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toEntity', () {
      test('convierte modelo a ProductEntity correctamente', () {
        // Arrange
        final model = createTestProductModel(
          id: 1,
          title: 'Test Product',
          price: 25.50,
          description: 'Test Description',
          category: 'test-category',
          image: 'https://test.com/image.png',
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<ProductEntity>());
        expect(entity.id, model.id);
        expect(entity.title, model.title);
        expect(entity.price, model.price);
        expect(entity.description, model.description);
        expect(entity.category, model.category);
        expect(entity.image, model.image);
      });

      test('entidad resultante es inmutable', () {
        // Arrange
        final model = createTestProductModel();

        // Act
        final entity = model.toEntity();

        // Assert - ProductEntity es Equatable e inmutable
        expect(entity.props, hasLength(6));
      });
    });

    group('constructor', () {
      test('crea instancia con const constructor', () {
        // Act
        const model = ProductModel(
          id: 1,
          title: 'Test',
          price: 10.0,
          description: 'Desc',
          category: 'Cat',
          image: 'img.jpg',
        );

        // Assert
        expect(model.id, 1);
        expect(model.title, 'Test');
      });

      test('dos modelos const con mismos valores son idénticos', () {
        // Arrange
        const model1 = ProductModel(
          id: 1,
          title: 'Test',
          price: 10.0,
          description: 'Desc',
          category: 'Cat',
          image: 'img.jpg',
        );
        const model2 = ProductModel(
          id: 1,
          title: 'Test',
          price: 10.0,
          description: 'Desc',
          category: 'Cat',
          image: 'img.jpg',
        );

        // Assert
        expect(identical(model1, model2), isTrue);
      });
    });
  });
}
