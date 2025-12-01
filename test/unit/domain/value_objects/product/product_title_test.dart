/// Tests para [ProductTitle] Value Object.
///
/// ESPECIFICACIÓN: ProductTitle
///
/// Responsabilidad: Representar el título de un producto con validaciones.
///
/// Invariantes:
///   - No puede ser vacío
///   - No puede ser solo espacios en blanco
///   - Longitud máxima de 200 caracteres
///
/// Errores:
///   - ArgumentError si está vacío
///   - ArgumentError si excede longitud máxima
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/value_objects/product/product_title.dart';

void main() {
  group('ProductTitle', () {
    group('creación', () {
      test('crea ProductTitle con valor válido', () {
        // Arrange & Act
        final title = ProductTitle('Laptop Gaming Pro');

        // Assert
        expect(title.value, equals('Laptop Gaming Pro'));
      });

      test('crea ProductTitle con un solo carácter', () {
        // Arrange & Act
        final title = ProductTitle('A');

        // Assert
        expect(title.value, equals('A'));
      });

      test('crea ProductTitle con longitud máxima (200)', () {
        // Arrange
        final longTitle = 'A' * 200;

        // Act
        final title = ProductTitle(longTitle);

        // Assert
        expect(title.value.length, equals(200));
      });

      test('elimina espacios al inicio y final (trim)', () {
        // Arrange & Act
        final title = ProductTitle('  Laptop Gaming  ');

        // Assert
        expect(title.value, equals('Laptop Gaming'));
      });

      test('lanza ArgumentError con string vacío', () {
        // Arrange & Act & Assert
        expect(() => ProductTitle(''), throwsA(isA<ArgumentError>()));
      });

      test('lanza ArgumentError con solo espacios en blanco', () {
        // Arrange & Act & Assert
        expect(() => ProductTitle('   '), throwsA(isA<ArgumentError>()));
      });

      test('lanza ArgumentError con longitud mayor a 200', () {
        // Arrange
        final tooLongTitle = 'A' * 201;

        // Act & Assert
        expect(() => ProductTitle(tooLongTitle), throwsA(isA<ArgumentError>()));
      });
    });

    group('igualdad', () {
      test('dos ProductTitle con mismo valor son iguales', () {
        // Arrange
        final t1 = ProductTitle('Laptop');
        final t2 = ProductTitle('Laptop');

        // Assert
        expect(t1, equals(t2));
        expect(t1.hashCode, equals(t2.hashCode));
      });

      test('dos ProductTitle con diferente valor no son iguales', () {
        // Arrange
        final t1 = ProductTitle('Laptop');
        final t2 = ProductTitle('Desktop');

        // Assert
        expect(t1, isNot(equals(t2)));
      });

      test('ProductTitle es case-sensitive', () {
        // Arrange
        final t1 = ProductTitle('laptop');
        final t2 = ProductTitle('Laptop');

        // Assert
        expect(t1, isNot(equals(t2)));
      });
    });

    group('formato', () {
      test('toString retorna el valor del título', () {
        // Arrange
        final title = ProductTitle('Laptop Gaming');

        // Act & Assert
        expect(title.toString(), contains('Laptop Gaming'));
      });
    });
  });
}
