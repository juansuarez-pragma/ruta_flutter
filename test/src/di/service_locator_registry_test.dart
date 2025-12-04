import 'package:test/test.dart';
import 'package:fase_2_consumo_api/src/di/service_locator_registry.dart';
import 'package:fase_2_consumo_api/src/di/contracts/service_locator_contract.dart';
import 'package:fase_2_consumo_api/src/di/adapters/get_it_adapter.dart';
import 'package:fase_2_consumo_api/src/di/adapters/kiwi_adapter.dart';

void main() {
  group('ServiceLocatorRegistry', () {
    group('get', () {
      test('retorna GetItAdapter cuando se solicita AdapterType.getIt', () {
        // Act
        final adapter = ServiceLocatorRegistry.get(AdapterType.getIt);

        // Assert
        expect(adapter, isA<ServiceLocatorContract>());
        expect(adapter, isA<GetItAdapter>());
      });

      test('retorna KiwiAdapter cuando se solicita AdapterType.kiwi', () {
        // Act
        final adapter = ServiceLocatorRegistry.get(AdapterType.kiwi);

        // Assert
        expect(adapter, isA<ServiceLocatorContract>());
        expect(adapter, isA<KiwiAdapter>());
      });

      test('retorna nueva instancia en cada llamada', () {
        // Act
        final adapter1 = ServiceLocatorRegistry.get(AdapterType.getIt);
        final adapter2 = ServiceLocatorRegistry.get(AdapterType.getIt);

        // Assert
        expect(identical(adapter1, adapter2), isFalse);
      });
    });
  });

  group('AdapterType', () {
    test('tiene valor getIt', () {
      expect(AdapterType.getIt.name, equals('getIt'));
    });

    test('tiene valor kiwi', () {
      expect(AdapterType.kiwi.name, equals('kiwi'));
    });
  });
}
