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

final sl = GetIt.instance;

/// Inicializa todas las dependencias de la aplicación.
///
/// Debe llamarse después de [EnvConfig.instance.initialize()].
Future<void> init() async {
  // Configuración
  sl.registerLazySingleton<EnvConfig>(() => EnvConfig.instance);

  // Presentation - User Interface (Port/Adapter Pattern)
  // Para cambiar la UI, registrar otra implementación de UserInterface
  sl.registerLazySingleton<UserInterface>(() => ConsoleUserInterface());

  // Presentation - Application
  sl.registerFactory(
    () => Application(
      ui: sl<UserInterface>(),
      getAllProducts: sl(),
      getProductById: sl(),
      getAllCategories: sl(),
      onExit: () => sl<http.Client>().close(),
    ),
  );

  // Use Cases
  sl.registerFactory(() => GetAllProductsUseCase(sl()));
  sl.registerFactory(() => GetProductByIdUseCase(sl()));
  sl.registerFactory(() => GetAllCategoriesUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ApiDataSource>(
    () => ApiDataSourceImpl(client: sl(), responseHandler: sl(), config: sl()),
  );

  // Core
  sl.registerLazySingleton(() => ApiResponseHandler());
  sl.registerLazySingleton(() => http.Client());
}
