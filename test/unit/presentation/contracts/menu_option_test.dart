import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';

void main() {
  group('MenuOption', () {
    test('contiene todas las opciones esperadas', () {
      // Assert
      expect(MenuOption.values, contains(MenuOption.getAllProducts));
      expect(MenuOption.values, contains(MenuOption.getProductById));
      expect(MenuOption.values, contains(MenuOption.getAllCategories));
      expect(MenuOption.values, contains(MenuOption.getProductsByCategory));
      expect(MenuOption.values, contains(MenuOption.exit));
      expect(MenuOption.values, contains(MenuOption.invalid));
    });

    test('tiene exactamente 6 valores', () {
      expect(MenuOption.values.length, 6);
    });

    test('valores son distintos', () {
      // Arrange
      final values = MenuOption.values;
      final uniqueValues = values.toSet();

      // Assert
      expect(values.length, uniqueValues.length);
    });

    test('getAllProducts tiene índice 0', () {
      expect(MenuOption.getAllProducts.index, 0);
    });

    test('getProductsByCategory tiene índice 3', () {
      expect(MenuOption.getProductsByCategory.index, 3);
    });

    test('exit tiene índice 4', () {
      expect(MenuOption.exit.index, 4);
    });

    test('invalid tiene índice 5', () {
      expect(MenuOption.invalid.index, 5);
    });

    test('name retorna el nombre correcto', () {
      expect(MenuOption.getAllProducts.name, 'getAllProducts');
      expect(MenuOption.getProductById.name, 'getProductById');
      expect(MenuOption.getAllCategories.name, 'getAllCategories');
      expect(MenuOption.getProductsByCategory.name, 'getProductsByCategory');
      expect(MenuOption.exit.name, 'exit');
      expect(MenuOption.invalid.name, 'invalid');
    });
  });
}
