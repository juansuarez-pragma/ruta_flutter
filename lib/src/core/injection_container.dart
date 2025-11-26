import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/data/datasources/api_datasource.dart';
import 'package:fase_2_consumo_api/src/data/repositories/product_repository_impl.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';

final sl = GetIt.instance;

void init() {
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
    () => ApiDataSourceImpl(client: sl(), responseHandler: sl()),
  );

  // Core
  sl.registerLazySingleton(() => ApiResponseHandler());
  sl.registerLazySingleton(() => http.Client());
}
