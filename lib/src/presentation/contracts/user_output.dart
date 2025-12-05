import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';

/// Contrato para mostrar datos de usuarios.
abstract class UserOutput {
  /// Muestra una lista de usuarios.
  void showUsers(List<UserEntity> users);

  /// Muestra un usuario individual.
  void showUser(UserEntity user);
}
