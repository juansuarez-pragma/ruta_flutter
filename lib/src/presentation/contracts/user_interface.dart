import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

/// Enumeración que representa las opciones del menú principal.
enum MenuOption {
  getAllProducts,
  getProductById,
  getAllCategories,
  exit,
  invalid,
}

/// Puerto (Port) que define el contrato para cualquier interfaz de usuario.
///
/// Este patrón permite intercambiar la implementación de UI (consola, GUI,
/// web, móvil) sin afectar la lógica de negocio. Cada plataforma implementa
/// este contrato según sus capacidades.
///
/// Basado en el patrón Ports and Adapters (Hexagonal Architecture).
abstract class UserInterface {
  /// Muestra un mensaje de bienvenida al usuario.
  void showWelcome(String message);

  /// Muestra el menú principal y retorna la opción seleccionada.
  Future<MenuOption> showMainMenu();

  /// Solicita al usuario que ingrese un ID de producto.
  ///
  /// Retorna `null` si el usuario cancela o ingresa un valor inválido.
  Future<int?> promptProductId();

  /// Muestra un indicador de carga mientras se ejecuta una operación.
  void showLoading(String operationName);

  /// Oculta el indicador de carga.
  void hideLoading();

  /// Muestra un mensaje de error al usuario.
  void showError(String message);

  /// Muestra un mensaje de éxito al usuario.
  void showSuccess(String message);

  /// Muestra una lista de productos.
  void showProducts(List<ProductEntity> products);

  /// Muestra un producto individual.
  void showProduct(ProductEntity product);

  /// Muestra una lista de categorías.
  void showCategories(List<String> categories);

  /// Muestra un mensaje de despedida y limpia recursos.
  void showGoodbye();

  /// Libera recursos utilizados por la interfaz.
  ///
  /// Debe llamarse al finalizar la aplicación.
  void dispose();
}
