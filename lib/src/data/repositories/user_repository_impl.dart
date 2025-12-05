import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/datasources/user/user_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/repositories/base/base_repository.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/user_repository.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

/// Implementación del repositorio de usuarios.
///
/// Conecta la capa de dominio con la fuente de datos remota,
/// manejando errores y transformando modelos a entidades.
class UserRepositoryImpl extends BaseRepository implements UserRepository {
  final UserRemoteDataSource _userDataSource;

  UserRepositoryImpl({required UserRemoteDataSource userDataSource})
    : _userDataSource = userDataSource;

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers() async {
    return await handleRequest(() async {
      final userModels = await _userDataSource.getAll();
      return userModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(int id) async {
    return await handleRequest(() async {
      final userModel = await _userDataSource.getById(id);
      return userModel.toEntity();
    }, notFoundMessage: AppStrings.notFoundUserFailureMessage);
  }
}
