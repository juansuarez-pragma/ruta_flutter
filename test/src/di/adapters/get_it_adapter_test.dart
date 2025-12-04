import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:fase_2_consumo_api/src/di/adapters/get_it_adapter.dart';
import 'package:fase_2_consumo_api/src/di/contracts/service_locator_contract.dart';

void main() {
  group('GetItAdapter', () {
    late GetItAdapter adapter;
    late GetIt getIt;

    setUp(() {
      getIt = GetIt.asNewInstance();
      adapter = GetItAdapter(getIt: getIt);
    });

    tearDown(() async {
      await getIt.reset();
    });

    group('constructor', () {
      test('usa GetIt.instance cuando no se proporciona instancia', () {
        // Arrange & Act
        final defaultAdapter = GetItAdapter();

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
        expect(() => adapter<String>(), throwsA(isA<StateError>()));
      });
    });

    group('implementa ServiceLocatorContract', () {
      test('es una implementacion valida del contrato', () {
        expect(adapter, isA<ServiceLocatorContract>());
      });
    });
  });
}
