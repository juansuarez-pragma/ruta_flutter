/// Definición de mocks para testing.
///
/// Este archivo contiene las anotaciones para generar mocks automáticamente
/// usando mockito y build_runner.
///
/// Para regenerar los mocks, ejecutar:
/// ```bash
/// dart run build_runner build --delete-conflicting-outputs
/// ```
library;

import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:fase_2_consumo_api/src/core/config/env_reader.dart';
import 'package:fase_2_consumo_api/src/core/network/api_response_handler.dart';
import 'package:fase_2_consumo_api/src/data/datasources/category/category_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/datasources/core/api_client.dart';
import 'package:fase_2_consumo_api/src/data/datasources/product/product_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/datasources/user/user_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/datasources/cart/cart_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/cart_repository.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/user_repository.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_carts_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_users_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_cart_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_carts_by_user_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_products_by_category_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_user_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';

/// Genera mocks para todas las dependencias principales.
@GenerateMocks([
  // Domain - Repositories
  ProductRepository,
  UserRepository,
  CartRepository,

  // Domain - Use Cases
  GetAllProductsUseCase,
  GetProductByIdUseCase,
  GetAllCategoriesUseCase,
  GetProductsByCategoryUseCase,
  GetAllUsersUseCase,
  GetUserByIdUseCase,
  GetAllCartsUseCase,
  GetCartByIdUseCase,
  GetCartsByUserUseCase,

  // Data - DataSources
  ProductRemoteDataSource,
  CategoryRemoteDataSource,
  UserRemoteDataSource,
  CartRemoteDataSource,
  ApiClient,

  // Core
  ApiResponseHandler,
  EnvReader,

  // External
  http.Client,

  // Presentation
  UserInterface,
])
void main() {}
