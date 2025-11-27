// fase_2_consumo_api/util/strings.dart

class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // General
  static const String executionEnd = '--- FIN DE LA EJECUCIÓN ---';
  static const String welcomeMessage =
      '--- Bienvenido al Cliente Interactivo de Fake Store API ---\n';
  static const String separator =
      '--------------------------------------------------';

  // Menu
  static const String menuTitle = 'Por favor, elige una opción:';
  static const String menuOptionGetAllProducts = 'Obtener todos los productos';
  static const String menuOptionGetProductById = 'Obtener un producto por ID';
  static const String menuOptionGetAllCategories =
      'Obtener todas las categorías';
  static const String menuOptionExit = 'Salir';
  static const String menuPrompt = 'Opción:';

  // Prompts
  static const String promptProductId =
      'Por favor, ingresa el ID del producto:';

  // Use Case Titles
  static const String getAllProductsUseCaseTitle = 'GetAllProductsUseCase';
  static const String getProductByIdUseCaseTitle = 'GetProductByIdUseCase';
  static const String getAllCategoriesUseCaseTitle = 'GetAllCategoriesUseCase';
  static const String executingUseCase = '[+] EJECUTANDO:';

  // Success Messages
  static const String successFound = '>> ÉXITO: Se encontraron';

  // Error Messages
  static const String errorPrefix = '>> ERROR:';
  static const String invalidOptionError =
      'Opción no válida. Por favor, intenta de nuevo.';
  static const String invalidIdError = 'ID no válido.';
  static const String serverFailureMessage = 'Error en el servidor.';
  static const String notFoundFailureMessage = 'Recurso no encontrado.';
  static const String notFoundProductFailureMessage = 'Producto no encontrado.';
  static const String notFoundCategoriesFailureMessage =
      'Recurso de categorías no encontrado.';
  static const String clientFailureMessage = 'Error en la petición.';
  static const String connectionFailureMessage =
      'Error de conexión a internet.';
  static const String unexpectedFailureMessage = 'Error inesperado:';

  // Labels
  static const String productsLabel = 'productos.';
  static const String categoriesLabel = 'categorías.';
  static const String productLabel = 'Producto';

  // Product Details
  static const String productId = 'ID:';
  static const String productTitle = 'Título:';
  static const String productCategory = 'Categoría:';
  static const String productPrice = 'Precio:';
  static const String productDescription = 'Descripción:';
  static const String productImage = 'Imagen:';
}
