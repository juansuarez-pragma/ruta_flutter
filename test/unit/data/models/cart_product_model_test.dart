import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/data/models/cart_product_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/cart_product_entity.dart';

import '../../../fixtures/cart_fixtures.dart';

void main() {
  group('CartProductModel', () {
    group('fromJson', () {
      test('crea modelo desde JSON válido', () {
        // Act
        final model = CartProductModel.fromJson(validCartProductJson);

        // Assert
        expect(model.productId, 1);
        expect(model.quantity, 4);
      });

      test('lanza FormatException cuando falta productId', () {
        // Assert
        expect(
          () => CartProductModel.fromJson(incompleteCartProductJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('lanza FormatException cuando productId tiene tipo incorrecto', () {
        // Assert
        expect(
          () => CartProductModel.fromJson(wrongTypeCartProductJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('lanza FormatException cuando productId es cero', () {
        // Assert
        expect(
          () => CartProductModel.fromJson(zeroProductIdCartProductJson),
          throwsA(isA<FormatException>()),
        );
      });

      test('lanza FormatException cuando quantity es negativo', () {
        // Assert
        expect(
          () => CartProductModel.fromJson(negativeQuantityCartProductJson),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toEntity', () {
      test('convierte modelo a CartProductEntity correctamente', () {
        // Arrange
        const model = CartProductModel(productId: 1, quantity: 4);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<CartProductEntity>());
        expect(entity.productId, model.productId);
        expect(entity.quantity, model.quantity);
      });
    });

    group('toJson', () {
      test('convierte modelo a JSON correctamente', () {
        // Arrange
        const model = CartProductModel(productId: 1, quantity: 4);

        // Act
        final json = model.toJson();

        // Assert
        expect(json['productId'], 1);
        expect(json['quantity'], 4);
      });
    });

    group('constructor', () {
      test('crea instancia con const constructor', () {
        // Act
        const model = CartProductModel(productId: 1, quantity: 4);

        // Assert
        expect(model.productId, 1);
        expect(model.quantity, 4);
      });

      test('dos modelos const con mismos valores son idénticos', () {
        // Arrange
        const model1 = CartProductModel(productId: 1, quantity: 4);
        const model2 = CartProductModel(productId: 1, quantity: 4);

        // Assert
        expect(identical(model1, model2), isTrue);
      });
    });
  });
}
