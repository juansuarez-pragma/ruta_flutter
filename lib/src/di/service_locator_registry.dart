import 'adapters/get_it_adapter.dart';
import 'adapters/kiwi_adapter.dart';
import 'contracts/service_locator_contract.dart';

/// Tipos de adaptadores disponibles para inyeccion de dependencias.
enum AdapterType {
  /// Adaptador usando la libreria GetIt.
  getIt,

  /// Adaptador usando la libreria Kiwi.
  kiwi,
}

class ServiceLocatorRegistry {
  ServiceLocatorRegistry._();

  static final Map<AdapterType, ServiceLocatorContract Function()> _factories = {
    AdapterType.getIt: GetItAdapter.new,
    AdapterType.kiwi: KiwiAdapter.new,
  };

  /// Obtiene una instancia del adaptador especificado.
  static ServiceLocatorContract get(AdapterType type) => _factories[type]!();
}
