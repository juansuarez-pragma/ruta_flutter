import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('ProductEntity', () {
    test('crea instancia con datos válidos', () {
      // Arrange & Act
      final product = createTestProductEntity();

      // Assert
      expect(product.id, 1);
      expect(product.title, 'Producto de prueba');
      expect(product.price, 99.99);
      expect(product.description, 'Descripción del producto de prueba');
      expect(product.category, 'electronics');
      expect(product.image, 'https://example.com/image.jpg');
    });

    test('dos entidades con mismas propiedades son iguales', () {
      // Arrange
      final product1 = createTestProductEntity(id: 1, title: 'Test');
      final product2 = createTestProductEntity(id: 1, title: 'Test');

      // Act & Assert
      expect(product1, equals(product2));
      expect(product1.hashCode, equals(product2.hashCode));
    });

    test('dos entidades con diferentes propiedades no son iguales', () {
      // Arrange
      final product1 = createTestProductEntity(id: 1);
      final product2 = createTestProductEntity(id: 2);

      // Act & Assert
      expect(product1, isNot(equals(product2)));
    });

    test('props contiene todos los campos', () {
      // Arrange
      final product = createTestProductEntity(
        id: 1,
        title: 'Test',
        price: 10.0,
        description: 'Desc',
        category: 'Cat',
        image: 'img.jpg',
      );

      // Act
      final props = product.props;

      // Assert
      expect(props, hasLength(6));
      expect(props, contains(1));
      expect(props, contains('Test'));
      expect(props, contains(10.0));
      expect(props, contains('Desc'));
      expect(props, contains('Cat'));
      expect(props, contains('img.jpg'));
    });

    test('entidad es inmutable al usar const constructor', () {
      // Arrange & Act
      const product1 = ProductEntity(
        id: 1,
        title: 'Test',
        price: 10.0,
        description: 'Desc',
        category: 'Cat',
        image: 'img.jpg',
      );

      const product2 = ProductEntity(
        id: 1,
        title: 'Test',
        price: 10.0,
        description: 'Desc',
        category: 'Cat',
        image: 'img.jpg',
      );

      // Assert - const instances are identical
      expect(identical(product1, product2), isTrue);
    });
  });
}
