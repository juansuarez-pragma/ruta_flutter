import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

/// Enumeración que representa las opciones del menú principal.
enum MenuOption {
  getAllProducts,
  getProductById,
  getAllCategories,
  exit,
  invalid,
}

/// Contrato para entrada de datos del usuario.
abstract class UserInput {
  /// Muestra el menú principal y retorna la opción seleccionada.
  Future<MenuOption> showMainMenu();

  /// Solicita al usuario que ingrese un ID de producto.
  ///
  /// Retorna `null` si el usuario cancela o ingresa un valor inválido.
  Future<int?> promptProductId();
}

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

/// Contrato para mostrar datos de productos.
abstract class ProductOutput {
  /// Muestra una lista de productos.
  void showProducts(List<ProductEntity> products);

  /// Muestra un producto individual.
  void showProduct(ProductEntity product);
}

/// Contrato para mostrar datos de categorías.
abstract class CategoryOutput {
  /// Muestra una lista de categorías.
  void showCategories(List<String> categories);
}

/// Puerto (Port) que combina todos los contratos de UI necesarios.
///
/// Este patrón permite intercambiar la implementación de UI (consola, GUI,
/// web, móvil) sin afectar la lógica de negocio. Cada plataforma implementa
/// estos contratos según sus capacidades.
///
/// Basado en el patrón Ports and Adapters (Hexagonal Architecture)
/// aplicando Interface Segregation Principle (ISP).
abstract class UserInterface
    implements UserInput, MessageOutput, ProductOutput, CategoryOutput {}
