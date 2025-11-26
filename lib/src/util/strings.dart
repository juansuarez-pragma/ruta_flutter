// fase_2_consumo_api/util/strings.dart

class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // General
  static const String appTitle = '--- INICIANDO EJECUCIÓN DE CASOS DE USO ---';
  static const String executionEnd = '--- FIN DE LA EJECUCIÓN ---';

  // Use Case Titles
  static const String getAllProductsUseCaseTitle = 'GetAllProductsUseCase';
  static const String getProductByIdUseCaseTitle = 'GetProductByIdUseCase (ID: 5)';
  static const String getAllCategoriesUseCaseTitle = 'GetAllCategoriesUseCase';
  static const String executingUseCase = '[+] EJECUTANDO:';

  // Success Messages
  static const String successFound = '>> ÉXITO: Se encontraron';

  // Error Messages
  static const String errorPrefix = '>> ERROR:';
  static const String serverFailureMessage = 'Error en el servidor.';
  static const String notFoundFailureMessage = 'Recurso no encontrado.';
  static const String notFoundProductFailureMessage = 'Producto no encontrado.';
  static const String notFoundCategoriesFailureMessage = 'Recurso de categorías no encontrado.';
  static const String clientFailureMessage = 'Error en la petición.';
  static const String connectionFailureMessage = 'Error de conexión a internet.';
  static const String unexpectedFailureMessage = 'Error inesperado:';

  // Product Details
  static const String productId = 'ID:';
  static const String productTitle = 'Título:';
  static const String productCategory = 'Categoría:';
  static const String productPrice = 'Precio:';
  static const String productDescription = 'Descripción:';
  static const String productImage = 'Imagen:';
}
