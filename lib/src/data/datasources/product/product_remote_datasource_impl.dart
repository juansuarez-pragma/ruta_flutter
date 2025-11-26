import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/core/api_client.dart';
import 'package:fase_2_consumo_api/src/data/datasources/product/product_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/models/product_model.dart';

/// Implementación de [ProductRemoteDataSource] usando [ApiClient].
///
/// Esta clase solo define qué endpoints usar y cómo mapear las respuestas.
/// Toda la lógica de HTTP, manejo de errores y parseo está en [ApiClient].
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ProductModel>> getAll() {
    return _apiClient.getList(
      endpoint: ApiEndpoints.products,
      fromJsonList: ProductModel.fromJson,
    );
  }

  @override
  Future<ProductModel> getById(int id) {
    return _apiClient.get(
      endpoint: ApiEndpoints.productById(id),
      fromJson: (json) => ProductModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
