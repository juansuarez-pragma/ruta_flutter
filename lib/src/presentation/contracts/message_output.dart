/// Contrato para mostrar mensajes al usuario.
abstract class MessageOutput {
  /// Muestra un mensaje de bienvenida al usuario.
  void showWelcome(String message);

  /// Muestra un mensaje de error al usuario.
  void showError(String message);

  /// Muestra un mensaje de despedida.
  void showGoodbye();

  /// Muestra información sobre la operación en curso.
  void showOperationInfo(String operationName);
}
