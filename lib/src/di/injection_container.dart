import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/config/config.dart';
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/data/datasources/datasources.dart';
import 'package:fase_2_consumo_api/src/data/repositories/product_repository_impl.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_products_by_category_usecase.dart';
import 'package:fase_2_consumo_api/src/presentation/adapters/console_user_interface.dart';
import 'package:fase_2_consumo_api/src/presentation/application.dart'
    show ApplicationController;
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';

/// Instancia global del Service Locator para inyección de dependencias.

final GetIt serviceLocator = GetIt.instance;

/// Tipos de registro:
/// - `registerFactory`: Nueva instancia en cada llamada (Use Cases, Application)
/// - `registerLazySingleton`: Instancia única, creada cuando se necesita
Future<void> init() async {
  // ============================================
  // Configuración
  // ============================================
  serviceLocator.registerLazySingleton<EnvConfig>(() => EnvConfig.instance);

  // ============================================
  // Capa de Presentación
  // ============================================

  // Interfaz de Usuario (Patrón Port/Adapter)
  // Para cambiar la UI, registrar otra implementación de UserInterface
  serviceLocator.registerLazySingleton<UserInterface>(
    () => ConsoleUserInterface(),
  );

  // ApplicationController - Coordinador principal
  serviceLocator.registerFactory(
    () => ApplicationController(
      ui: serviceLocator<UserInterface>(),
      getAllProducts: serviceLocator(),
      getProductById: serviceLocator(),
      getAllCategories: serviceLocator(),
      onExit: () => serviceLocator<http.Client>().close(),
    ),
  );

  // ============================================
  // Capa de Dominio - Casos de Uso
  // ============================================
  serviceLocator.registerFactory(() => GetAllProductsUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => GetProductByIdUseCase(serviceLocator()));
  serviceLocator.registerFactory(
    () => GetAllCategoriesUseCase(serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => GetProductsByCategoryUseCase(serviceLocator()),
  );

  // ============================================
  // Capa de Datos - Repositorio
  // ============================================
  serviceLocator.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      productDataSource: serviceLocator(),
      categoryDataSource: serviceLocator(),
    ),
  );

  // ============================================
  // Capa de Datos - Fuentes de Datos
  // ============================================
  serviceLocator.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiClient: serviceLocator()),
  );

  // ============================================
  // Core - Red
  // ============================================
  serviceLocator.registerLazySingleton<ApiClient>(
    () => ApiClientImpl(
      client: serviceLocator(),
      responseHandler: serviceLocator(),
      config: serviceLocator(),
    ),
  );
  serviceLocator.registerLazySingleton(() => ApiResponseHandler());
  serviceLocator.registerLazySingleton(() => http.Client());
}
