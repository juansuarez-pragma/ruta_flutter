import 'package:fase_2_consumo_api/src/presentation/contracts/menu_option.dart';

/// Contrato para entrada de datos del usuario.
abstract class UserInput {
  /// Muestra el menú principal y retorna la opción seleccionada.
  Future<MenuOption> showMainMenu();

  /// Solicita al usuario que ingrese un ID de producto.
  ///
  /// Retorna `null` si el usuario cancela o ingresa un valor inválido.
  Future<int?> promptProductId();
}
