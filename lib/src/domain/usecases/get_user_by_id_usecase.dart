import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/user_repository.dart';

/// Caso de uso para obtener un usuario por su ID.
class GetUserByIdUseCase implements UseCase<UserEntity, GetUserByIdParams> {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetUserByIdParams params) async {
    return await repository.getUserById(params.id);
  }
}

/// Parámetros para el caso de uso [GetUserByIdUseCase].
class GetUserByIdParams extends Equatable {
  final int id;

  const GetUserByIdParams({required this.id});

  @override
  List<Object?> get props => [id];
}
