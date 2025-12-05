import 'package:fase_2_consumo_api/src/data/models/user_model.dart';

/// Interface para el origen de datos remoto de usuarios.
abstract class UserRemoteDataSource {
  /// Obtiene todos los usuarios desde la API.
  Future<List<UserModel>> getAll();

  /// Obtiene un usuario por su ID.
  Future<UserModel> getById(int id);
}
