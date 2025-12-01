/// Tests para [ProductId] Value Object.
///
/// ESPECIFICACIÓN: ProductId
///
/// Responsabilidad: Representar el identificador único de un producto.
///
/// Invariantes:
///   - Valor debe ser un entero positivo (> 0)
///
/// Errores:
///   - ArgumentError si valor <= 0
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_id.dart';

void main() {
  group('ProductId', () {
    group('creación', () {
      test('crea ProductId con valor válido positivo', () {
        // Arrange & Act
        final id = ProductId(1);

        // Assert
        expect(id.value, equals(1));
      });

      test('crea ProductId con valor grande', () {
        // Arrange & Act
        final id = ProductId(999999);

        // Assert
        expect(id.value, equals(999999));
      });

      test('lanza ArgumentError con valor cero', () {
        // Arrange & Act & Assert
        expect(() => ProductId(0), throwsA(isA<ArgumentError>()));
      });

      test('lanza ArgumentError con valor negativo', () {
        // Arrange & Act & Assert
        expect(() => ProductId(-1), throwsA(isA<ArgumentError>()));
      });

      test('lanza ArgumentError con valor muy negativo', () {
        // Arrange & Act & Assert
        expect(() => ProductId(-999), throwsA(isA<ArgumentError>()));
      });
    });

    group('igualdad', () {
      test('dos ProductId con mismo valor son iguales', () {
        // Arrange
        final id1 = ProductId(5);
        final id2 = ProductId(5);

        // Assert
        expect(id1, equals(id2));
        expect(id1.hashCode, equals(id2.hashCode));
      });

      test('dos ProductId con diferente valor no son iguales', () {
        // Arrange
        final id1 = ProductId(5);
        final id2 = ProductId(10);

        // Assert
        expect(id1, isNot(equals(id2)));
      });
    });

    group('formato', () {
      test('toString muestra el valor', () {
        // Arrange
        final id = ProductId(42);

        // Act & Assert
        expect(id.toString(), contains('42'));
      });
    });
  });
}
