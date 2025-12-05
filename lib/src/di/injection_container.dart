import 'package:http/http.dart' as http;

import 'package:fase_2_consumo_api/src/core/config/config.dart';
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/data/datasources/datasources.dart';
import 'package:fase_2_consumo_api/src/data/repositories/product_repository_impl.dart';
import 'package:fase_2_consumo_api/src/data/repositories/user_repository_impl.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/user_repository.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_users_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_products_by_category_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_user_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/presentation/adapters/console_user_interface.dart';
import 'package:fase_2_consumo_api/src/presentation/application.dart'
    show ApplicationController;
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';

import 'adapters/get_it_adapter.dart';
import 'contracts/service_locator_contract.dart';

/// Contenedor de inyeccion de dependencias.
final ServiceLocatorContract _container = GetItAdapter();

Future<ApplicationController> init() async {
  // ============================================
  // Configuración
  // ============================================
  _container.registerLazySingleton<EnvConfig>(() => EnvConfig.instance);

  // ============================================
  // Capa de Presentación
  // ============================================

  // Interfaz de Usuario (Patrón Port/Adapter)
  // Para cambiar la UI, registrar otra implementación de UserInterface
  _container.registerLazySingleton<UserInterface>(() => ConsoleUserInterface());

  // ApplicationController - Coordinador principal
  _container.registerFactory(
    () => ApplicationController(
      ui: _container<UserInterface>(),
      getAllProducts: _container(),
      getProductById: _container(),
      getAllCategories: _container(),
      getProductsByCategory: _container(),
      getAllUsers: _container(),
      getUserById: _container(),
      onExit: () => _container<http.Client>().close(),
    ),
  );

  // ============================================
  // Capa de Dominio - Casos de Uso
  // ============================================
  _container.registerFactory(() => GetAllProductsUseCase(_container()));
  _container.registerFactory(() => GetProductByIdUseCase(_container()));
  _container.registerFactory(() => GetAllCategoriesUseCase(_container()));
  _container.registerFactory(() => GetProductsByCategoryUseCase(_container()));
  _container.registerFactory(() => GetAllUsersUseCase(_container()));
  _container.registerFactory(() => GetUserByIdUseCase(_container()));

  // ============================================
  // Capa de Datos - Repositorio
  // ============================================
  _container.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      productDataSource: _container(),
      categoryDataSource: _container(),
    ),
  );
  _container.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(userDataSource: _container()),
  );

  // ============================================
  // Capa de Datos - Fuentes de Datos
  // ============================================
  _container.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: _container()),
  );
  _container.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiClient: _container()),
  );
  _container.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiClient: _container()),
  );

  // ============================================
  // Core - Red
  // ============================================
  _container.registerLazySingleton<ApiClient>(
    () => ApiClientImpl(
      client: _container(),
      responseHandler: _container(),
      config: _container(),
    ),
  );
  _container.registerLazySingleton(() => ApiResponseHandler());
  _container.registerLazySingleton(() => http.Client());

  // Retorna el controlador raiz con todas las dependencias inyectadas
  return _container<ApplicationController>();
}
