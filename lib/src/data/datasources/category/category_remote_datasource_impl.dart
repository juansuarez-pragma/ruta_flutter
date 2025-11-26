import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/category/category_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/datasources/core/api_client.dart';

/// Implementación de [CategoryRemoteDataSource] usando [ApiClient].
///
/// Esta clase solo define qué endpoints usar y cómo mapear las respuestas.
/// Toda la lógica de HTTP, manejo de errores y parseo está en [ApiClient].
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;

  CategoryRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<String>> getAll() {
    return _apiClient.getPrimitiveList<String>(
      endpoint: ApiEndpoints.categories,
    );
  }
}
