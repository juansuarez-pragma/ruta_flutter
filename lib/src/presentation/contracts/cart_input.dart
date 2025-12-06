/// Contrato para entrada de datos relacionados con carritos.
abstract class CartInput {
  /// Solicita al usuario que ingrese un ID de carrito.
  ///
  /// Retorna `null` si el usuario cancela o ingresa un valor inválido.
  Future<int?> promptCartId();

  /// Solicita al usuario que ingrese un ID de usuario para buscar sus carritos.
  ///
  /// Retorna `null` si el usuario cancela o ingresa un valor inválido.
  Future<int?> promptUserIdForCarts();
}
