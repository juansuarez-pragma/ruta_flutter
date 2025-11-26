import 'package:equatable/equatable.dart';

/// Clase base abstracta para representar fallos en la aplicación.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}
