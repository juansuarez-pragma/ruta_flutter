/// Tests para [Money] Value Object.
///
/// ESPECIFICACIÓN: Money
///
/// Responsabilidad: Representar un valor monetario no negativo con precisión.
///
/// Invariantes:
///   - Valor debe ser >= 0
///   - Precisión de 2 decimales
///
/// Operaciones:
///   - add(Money): Suma dos valores monetarios
///   - subtract(Money): Resta (resultado no puede ser negativo)
///   - multiply(int): Multiplica por cantidad
///   - compareTo(Money): Comparación para ordenamiento
///
/// Factory:
///   - Money.fromDouble(double): Crea desde double con validación
///   - Money.zero: Valor cero constante
///
/// Errores:
///   - ArgumentError si valor < 0
///   - ArgumentError si resta resulta en negativo
library;

import 'package:test/test.dart';

import 'package:fase_2_consumo_api/src/domain/value_objects/shared/money.dart';

void main() {
  group('Money', () {
    group('creación', () {
      test('crea Money con valor válido positivo', () {
        // Arrange & Act
        final money = Money.fromDouble(99.99);

        // Assert
        expect(money.value, equals(99.99));
      });

      test('crea Money con valor cero', () {
        // Arrange & Act
        final money = Money.fromDouble(0.0);

        // Assert
        expect(money.value, equals(0.0));
      });

      test('redondea a 2 decimales', () {
        // Arrange & Act
        final money = Money.fromDouble(99.999);

        // Assert
        expect(money.value, equals(100.0));
      });

      test('lanza ArgumentError con valor negativo', () {
        // Arrange & Act & Assert
        expect(() => Money.fromDouble(-1.0), throwsA(isA<ArgumentError>()));
      });

      test('Money.zero retorna valor cero', () {
        // Arrange & Act & Assert
        expect(Money.zero.value, equals(0.0));
      });

      test('Money.zero es singleton', () {
        // Arrange & Act & Assert
        expect(identical(Money.zero, Money.zero), isTrue);
      });
    });

    group('operaciones aritméticas', () {
      test('add suma dos valores correctamente', () {
        // Arrange
        final m1 = Money.fromDouble(10.50);
        final m2 = Money.fromDouble(5.25);

        // Act
        final result = m1.add(m2);

        // Assert
        expect(result.value, equals(15.75));
      });

      test('add con cero retorna mismo valor', () {
        // Arrange
        final money = Money.fromDouble(50.00);

        // Act
        final result = money.add(Money.zero);

        // Assert
        expect(result.value, equals(50.00));
      });

      test('subtract resta correctamente', () {
        // Arrange
        final m1 = Money.fromDouble(10.00);
        final m2 = Money.fromDouble(3.50);

        // Act
        final result = m1.subtract(m2);

        // Assert
        expect(result.value, equals(6.50));
      });

      test('subtract con mismo valor retorna cero', () {
        // Arrange
        final money = Money.fromDouble(25.00);

        // Act
        final result = money.subtract(money);

        // Assert
        expect(result.value, equals(0.0));
      });

      test('subtract lanza error si resultado sería negativo', () {
        // Arrange
        final m1 = Money.fromDouble(5.00);
        final m2 = Money.fromDouble(10.00);

        // Act & Assert
        expect(() => m1.subtract(m2), throwsA(isA<ArgumentError>()));
      });

      test('multiply multiplica correctamente', () {
        // Arrange
        final money = Money.fromDouble(10.00);

        // Act
        final result = money.multiply(3);

        // Assert
        expect(result.value, equals(30.00));
      });

      test('multiply por cero retorna cero', () {
        // Arrange
        final money = Money.fromDouble(100.00);

        // Act
        final result = money.multiply(0);

        // Assert
        expect(result.value, equals(0.0));
      });

      test('multiply por uno retorna mismo valor', () {
        // Arrange
        final money = Money.fromDouble(75.50);

        // Act
        final result = money.multiply(1);

        // Assert
        expect(result.value, equals(75.50));
      });
    });

    group('comparación', () {
      test('dos Money con mismo valor son iguales', () {
        // Arrange
        final m1 = Money.fromDouble(99.99);
        final m2 = Money.fromDouble(99.99);

        // Assert
        expect(m1, equals(m2));
        expect(m1.hashCode, equals(m2.hashCode));
      });

      test('dos Money con diferente valor no son iguales', () {
        // Arrange
        final m1 = Money.fromDouble(99.99);
        final m2 = Money.fromDouble(100.00);

        // Assert
        expect(m1, isNot(equals(m2)));
      });

      test('compareTo ordena correctamente', () {
        // Arrange
        final m1 = Money.fromDouble(10.00);
        final m2 = Money.fromDouble(20.00);

        // Assert
        expect(m1.compareTo(m2), lessThan(0));
        expect(m2.compareTo(m1), greaterThan(0));
        expect(m1.compareTo(m1), equals(0));
      });

      test('operador < funciona correctamente', () {
        // Arrange
        final m1 = Money.fromDouble(10.00);
        final m2 = Money.fromDouble(20.00);

        // Assert
        expect(m1 < m2, isTrue);
        expect(m2 < m1, isFalse);
      });

      test('operador <= funciona correctamente', () {
        // Arrange
        final m1 = Money.fromDouble(10.00);
        final m2 = Money.fromDouble(10.00);
        final m3 = Money.fromDouble(20.00);

        // Assert
        expect(m1 <= m2, isTrue);
        expect(m1 <= m3, isTrue);
        expect(m3 <= m1, isFalse);
      });

      test('operador > funciona correctamente', () {
        // Arrange
        final m1 = Money.fromDouble(20.00);
        final m2 = Money.fromDouble(10.00);

        // Assert
        expect(m1 > m2, isTrue);
        expect(m2 > m1, isFalse);
      });

      test('operador >= funciona correctamente', () {
        // Arrange
        final m1 = Money.fromDouble(20.00);
        final m2 = Money.fromDouble(20.00);
        final m3 = Money.fromDouble(10.00);

        // Assert
        expect(m1 >= m2, isTrue);
        expect(m1 >= m3, isTrue);
        expect(m3 >= m1, isFalse);
      });
    });

    group('formato', () {
      test('toString muestra formato de moneda con símbolo', () {
        // Arrange
        final money = Money.fromDouble(99.99);

        // Act & Assert
        expect(money.toString(), equals('\$99.99'));
      });

      test('toString muestra dos decimales siempre', () {
        // Arrange
        final money = Money.fromDouble(100.00);

        // Act & Assert
        expect(money.toString(), equals('\$100.00'));
      });

      test('toString formatea valor entero con decimales', () {
        // Arrange
        final money = Money.fromDouble(50);

        // Act & Assert
        expect(money.toString(), equals('\$50.00'));
      });
    });
  });
}
