import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/user_repository.dart';

/// Caso de uso para obtener todos los usuarios.
class GetAllUsersUseCase implements UseCase<List<UserEntity>, NoParams> {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await repository.getAllUsers();
  }
}
