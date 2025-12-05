import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';

/// Interfaz del repositorio de usuarios.
///
/// Define el contrato para acceder a los datos de usuarios.
/// La implementación concreta está en la capa de datos.
abstract class UserRepository {
  /// Obtiene todos los usuarios.
  Future<Either<Failure, List<UserEntity>>> getAllUsers();

  /// Obtiene un usuario por su ID.
  Future<Either<Failure, UserEntity>> getUserById(int id);
}
