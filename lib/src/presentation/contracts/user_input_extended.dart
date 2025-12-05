/// Contrato extendido para entrada de usuario con soporte de usuarios.
abstract class UserInputExtended {
  /// Solicita al usuario que ingrese un ID de usuario.
  Future<int?> promptUserId();
}
