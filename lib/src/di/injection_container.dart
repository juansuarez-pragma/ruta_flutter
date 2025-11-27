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
import 'package:fase_2_consumo_api/src/presentation/adapters/console_user_interface.dart';
import 'package:fase_2_consumo_api/src/presentation/application.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';

/// Instancia global del Service Locator para inyección de dependencias.
///
/// Usar nombres descriptivos en lugar de abreviaciones mejora la legibilidad
/// y facilita el mantenimiento del código.
final GetIt serviceLocator = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación.
///
/// Registra todas las implementaciones concretas para las abstracciones
/// definidas en la arquitectura. Debe llamarse después de
/// [EnvConfig.instance.initialize()].
///
/// Tipos de registro:
/// - `registerFactory`: Nueva instancia en cada llamada (Use Cases, Application)
/// - `registerLazySingleton`: Instancia única, creada cuando se necesita
Future<void> init() async {
  // ============================================
  // Configuración
  // ============================================
  serviceLocator.registerLazySingleton<EnvConfig>(() => EnvConfig.instance);

  // ============================================
  // Presentation Layer
  // ============================================

  // User Interface (Port/Adapter Pattern)
  // Para cambiar la UI, registrar otra implementación de UserInterface
  serviceLocator.registerLazySingleton<UserInterface>(
    () => ConsoleUserInterface(),
  );

  // Application - Coordinador principal
  serviceLocator.registerFactory(
    () => Application(
      ui: serviceLocator<UserInterface>(),
      getAllProducts: serviceLocator(),
      getProductById: serviceLocator(),
      getAllCategories: serviceLocator(),
      onExit: () => serviceLocator<http.Client>().close(),
    ),
  );

  // ============================================
  // Domain Layer - Use Cases
  // ============================================
  serviceLocator.registerFactory(() => GetAllProductsUseCase(serviceLocator()));
  serviceLocator.registerFactory(() => GetProductByIdUseCase(serviceLocator()));
  serviceLocator.registerFactory(
    () => GetAllCategoriesUseCase(serviceLocator()),
  );

  // ============================================
  // Data Layer - Repository
  // ============================================
  serviceLocator.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      productDataSource: serviceLocator(),
      categoryDataSource: serviceLocator(),
    ),
  );

  // ============================================
  // Data Layer - Data Sources
  // ============================================
  serviceLocator.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(apiClient: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(apiClient: serviceLocator()),
  );

  // ============================================
  // Core - Network
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
