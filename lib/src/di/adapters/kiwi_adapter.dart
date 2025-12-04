import 'package:kiwi/kiwi.dart';

import '../contracts/service_locator_contract.dart';

/// Implementacion de [ServiceLocatorContract] usando Kiwi.
class KiwiAdapter implements ServiceLocatorContract {
  final KiwiContainer _container;

  KiwiAdapter({KiwiContainer? container})
    : _container = container ?? KiwiContainer();

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _container.registerSingleton<T>((_) => factory());
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _container.registerFactory<T>((_) => factory());
  }

  @override
  T call<T extends Object>() => _container.resolve<T>();
}
