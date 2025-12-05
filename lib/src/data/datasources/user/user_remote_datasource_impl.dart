import 'package:fase_2_consumo_api/src/core/constants/api_endpoints.dart';
import 'package:fase_2_consumo_api/src/data/datasources/core/api_client.dart';
import 'package:fase_2_consumo_api/src/data/datasources/user/user_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/models/user_model.dart';

/// Implementación de [UserRemoteDataSource] usando [ApiClient].
///
/// Esta clase solo define qué endpoints usar y cómo mapear las respuestas.
/// Toda la lógica de HTTP, manejo de errores y parseo está en [ApiClient].
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<UserModel>> getAll() {
    return _apiClient.getList(
      endpoint: ApiEndpoints.users,
      fromJsonList: UserModel.fromJson,
    );
  }

  @override
  Future<UserModel> getById(int id) {
    return _apiClient.get(
      endpoint: ApiEndpoints.userById(id),
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
  }
}
