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

  // ============================================
  // Categorías
  // ============================================

  /// Obtener todas las categorías.
  /// GET /products/categories
  static const String categories = '/products/categories';
}
