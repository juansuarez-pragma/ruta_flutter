import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/core/api_client.dart';
import 'package:fase_2_consumo_api/src/data/datasources/cart/cart_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/models/cart_model.dart';

/// Implementación de [CartRemoteDataSource] usando [ApiClient].
///
/// Esta clase solo define qué endpoints usar y cómo mapear las respuestas.
/// Toda la lógica de HTTP, manejo de errores y parseo está en [ApiClient].
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;

  CartRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CartModel>> getAll() {
    return _apiClient.getList(
      endpoint: ApiEndpoints.carts,
      fromJsonList: CartModel.fromJson,
    );
  }

  @override
  Future<CartModel> getById(int id) {
    return _apiClient.get(
      endpoint: ApiEndpoints.cartById(id),
      fromJson: (json) => CartModel.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<List<CartModel>> getByUser(int userId) {
    return _apiClient.getList(
      endpoint: ApiEndpoints.cartsByUser(userId),
      fromJsonList: CartModel.fromJson,
    );
  }
}
