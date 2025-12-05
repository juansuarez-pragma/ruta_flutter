/// Constantes de endpoints de la API.
///
/// Centraliza todas las rutas de la API para facilitar el mantenimiento
/// y evitar strings duplicados en el código.
///
/// Ejemplo de uso:
/// ```dart
/// final uri = Uri.parse('${config.apiBaseUrl}${ApiEndpoints.products}');
/// ```
abstract class ApiEndpoints {
  ApiEndpoints._();

  // ============================================
  // Productos
  // ============================================

  /// Obtener todos los productos.
  /// GET /products
  static const String products = '/products';

  /// Obtener un producto por ID.
  /// GET /products/{id}
  static String productById(int id) => '/products/$id';

  /// Obtener productos por categoría.
  /// GET /products/category/{categoryName}
  static String productsByCategory(String category) =>
      '/products/category/$category';

  // ============================================
  // Categorías
  // ============================================

  /// Obtener todas las categorías.
  /// GET /products/categories
  static const String categories = '/products/categories';

  // ============================================
  // Usuarios
  // ============================================

  /// Obtener todos los usuarios.
  /// GET /users
  static const String users = '/users';

  /// Obtener un usuario por ID.
  /// GET /users/{id}
  static String userById(int id) => '/users/$id';
}
