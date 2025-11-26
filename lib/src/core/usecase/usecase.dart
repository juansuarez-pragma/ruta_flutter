import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
