import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/data/models/cart_model.dart';
import 'package:fase_2_consumo_api/src/data/models/cart_product_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';

import '../../../fixtures/cart_fixtures.dart';

void main() {
  group('CartModel', () {
    group('fromJson', () {
      test('crea modelo desde JSON válido', () {
        // Act
        final model = CartModel.fromJson(validCartJson);

        // Assert
        expect(model.id, 1);
        expect(model.userId, 1);
        expect(model.date, DateTime.parse('2020-03-02T00:00:00.000Z'));
        expect(model.products.length, 2);
        expect(model.products[0].productId, 1);
        expect(model.products[0].quantity, 4);
        expect(model.products[1].productId, 2);
        expect(model.products[1].quantity, 1);
      });

      test('crea modelo con lista de productos vacía', () {
        // Act
        final model = CartModel.fromJson(emptyCartJson);

        // Assert
        expect(model.id, 3);
        expect(model.products, isEmpty);
      });

      test('parsea fecha ISO 8601 correctamente', () {
        // Act
        final model = CartModel.fromJson(validCartJson);

        // Assert
        expect(model.date.year, 2020);
        expect(model.date.month, 3);
        expect(model.date.day, 2);
      });

      test('lanza FormatException cuando falta userId', () {
        // Assert
        expect(
          () => CartModel.fromJson(incompleteCartJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('lanza FormatException cuando id tiene tipo incorrecto', () {
        // Assert
        expect(
          () => CartModel.fromJson(wrongTypeCartJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('lanza FormatException cuando fecha tiene formato inválido', () {
        // Assert
        expect(
          () => CartModel.fromJson(invalidDateCartJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('lanza FormatException cuando products no es una lista', () {
        // Assert
        expect(
          () => CartModel.fromJson(invalidProductsCartJson),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toEntity', () {
      test('convierte modelo a CartEntity correctamente', () {
        // Arrange
        final model = CartModel.fromJson(validCartJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<CartEntity>());
        expect(entity.id, model.id);
        expect(entity.userId, model.userId);
        expect(entity.date, model.date);
        expect(entity.products.length, model.products.length);
      });

      test('convierte productos a CartProductEntity correctamente', () {
        // Arrange
        final model = CartModel.fromJson(validCartJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.products[0].productId, 1);
        expect(entity.products[0].quantity, 4);
      });
    });

    group('toJson', () {
      test('convierte modelo a JSON correctamente', () {
        // Arrange
        final model = CartModel(
          id: 1,
          userId: 1,
          date: DateTime.parse('2020-03-02T00:00:00.000Z'),
          products: const [
            CartProductModel(productId: 1, quantity: 4),
            CartProductModel(productId: 2, quantity: 1),
          ],
        );

        // Act
        final json = model.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['userId'], 1);
        expect(json['date'], '2020-03-02T00:00:00.000Z');
        expect(json['products'], isA<List>());
        expect((json['products'] as List).length, 2);
      });
    });

    group('constructor', () {
      test('crea instancia correctamente', () {
        // Act
        final model = CartModel(
          id: 1,
          userId: 1,
          date: DateTime.parse('2020-03-02T00:00:00.000Z'),
          products: const [],
        );

        // Assert
        expect(model.id, 1);
        expect(model.userId, 1);
        expect(model.products, isEmpty);
      });
    });
  });
}
