import 'package:test/test.dart';
import 'package:kiwi/kiwi.dart';
import 'package:fase_2_consumo_api/src/di/adapters/kiwi_adapter.dart';
import 'package:fase_2_consumo_api/src/di/contracts/service_locator_contract.dart';

void main() {
  group('KiwiAdapter', () {
    late KiwiAdapter adapter;
    late KiwiContainer container;

    setUp(() {
      container = KiwiContainer();
      adapter = KiwiAdapter(container: container);
    });

    tearDown(() {
      container.clear();
    });

    group('constructor', () {
      test('crea contenedor por defecto cuando no se proporciona uno', () {
        // Arrange & Act
        final defaultAdapter = KiwiAdapter();

        // Assert
        expect(defaultAdapter, isA<ServiceLocatorContract>());
      });
    });

    group('registerLazySingleton', () {
      test('registra y obtiene instancia unica', () {
        // Arrange
        var callCount = 0;
        adapter.registerLazySingleton<String>(() {
          callCount++;
          return 'singleton';
        });

        // Act
        final first = adapter<String>();
        final second = adapter<String>();

        // Assert
        expect(first, equals('singleton'));
        expect(second, equals('singleton'));
        expect(callCount, equals(1));
      });
    });

    group('registerFactory', () {
      test('crea nueva instancia en cada llamada', () {
        // Arrange
        var count = 0;
        adapter.registerFactory<int>(() => ++count);

        // Act
        final first = adapter<int>();
        final second = adapter<int>();
        final third = adapter<int>();

        // Assert
        expect(first, equals(1));
        expect(second, equals(2));
        expect(third, equals(3));
      });
    });

    group('call', () {
      test('obtiene instancia registrada', () {
        // Arrange
        adapter.registerLazySingleton<String>(() => 'test');

        // Act
        final result = adapter<String>();

        // Assert
        expect(result, equals('test'));
      });

      test('lanza excepcion para tipo no registrado', () {
        // Act & Assert
        expect(() => adapter<double>(), throwsA(isA<KiwiError>()));
      });
    });

    group('implementa ServiceLocatorContract', () {
      test('es una implementacion valida del contrato', () {
        expect(adapter, isA<ServiceLocatorContract>());
      });
    });
  });
}
