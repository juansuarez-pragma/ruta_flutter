import 'package:get_it/get_it.dart';

import '../contracts/service_locator_contract.dart';

/// Implementacion de [ServiceLocatorContract] usando GetIt.
class GetItAdapter implements ServiceLocatorContract {
  final GetIt _getIt;

  GetItAdapter({GetIt? getIt}) : _getIt = getIt ?? GetIt.instance;

  @override
  void registerLazySingleton<T extends Object>(T Function() factory) {
    _getIt.registerLazySingleton<T>(factory);
  }

  @override
  void registerFactory<T extends Object>(T Function() factory) {
    _getIt.registerFactory<T>(factory);
  }

  @override
  T call<T extends Object>() => _getIt<T>();
}
