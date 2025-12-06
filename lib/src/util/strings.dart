/// Constantes de texto para la interfaz de usuario.
///
/// Centraliza todos los strings de la aplicación para facilitar
/// mantenimiento e internacionalización futura.
class AppStrings {
  // Constructor privado para prevenir instanciación.
  AppStrings._();

  // General
  static const String executionEnd = '--- FIN DE LA EJECUCIÓN ---';
  static const String welcomeMessage =
      '--- Bienvenido al Cliente Interactivo de Fake Store API ---\n';
  static const String separator =
      '--------------------------------------------------';

  // Menú
  static const String menuTitle = 'Por favor, elige una opción:';
  static const String menuOptionGetAllProducts = 'Obtener todos los productos';
  static const String menuOptionGetProductById = 'Obtener un producto por ID';
  static const String menuOptionGetAllCategories =
      'Obtener todas las categorías';
  static const String menuOptionGetProductsByCategory =
      'Obtener productos por categoría';
  static const String menuOptionGetAllUsers = 'Obtener todos los usuarios';
  static const String menuOptionGetUserById = 'Obtener un usuario por ID';
  static const String menuOptionGetAllCarts = 'Obtener todos los carritos';
  static const String menuOptionGetCartById = 'Obtener un carrito por ID';
  static const String menuOptionGetCartsByUser = 'Obtener carritos de un usuario';
  static const String menuOptionExit = 'Salir';
  static const String menuPrompt = 'Opción:';

  // Solicitudes
  static const String promptProductId =
      'Por favor, ingresa el ID del producto:';
  static const String promptUserId = 'Por favor, ingresa el ID del usuario:';
  static const String promptCategory = 'Selecciona una categoría (número):';
  static const String promptCartId = 'Por favor, ingresa el ID del carrito:';
  static const String promptUserIdForCarts =
      'Por favor, ingresa el ID del usuario para ver sus carritos:';
  static const String invalidCategoryError = 'Categoría no válida.';

  // Títulos de casos de uso
  static const String getAllProductsUseCaseTitle = 'GetAllProductsUseCase';
  static const String getProductByIdUseCaseTitle = 'GetProductByIdUseCase';
  static const String getAllCategoriesUseCaseTitle = 'GetAllCategoriesUseCase';
  static const String getProductsByCategoryUseCaseTitle =
      'GetProductsByCategoryUseCase';
  static const String getAllUsersUseCaseTitle = 'GetAllUsersUseCase';
  static const String getUserByIdUseCaseTitle = 'GetUserByIdUseCase';
  static const String getAllCartsUseCaseTitle = 'GetAllCartsUseCase';
  static const String getCartByIdUseCaseTitle = 'GetCartByIdUseCase';
  static const String getCartsByUserUseCaseTitle = 'GetCartsByUserUseCase';
  static const String executingUseCase = '[+] EJECUTANDO:';

  // Mensajes de éxito
  static const String successFound = '>> ÉXITO: Se encontraron';

  // Mensajes de error
  static const String errorPrefix = '>> ERROR:';
  static const String invalidOptionError =
      'Opción no válida. Por favor, intenta de nuevo.';
  static const String invalidIdError = 'ID no válido.';
  static const String serverFailureMessage = 'Error en el servidor.';
  static const String notFoundFailureMessage = 'Recurso no encontrado.';
  static const String notFoundProductFailureMessage = 'Producto no encontrado.';
  static const String notFoundCategoriesFailureMessage =
      'Recurso de categorías no encontrado.';
  static const String notFoundUserFailureMessage = 'Usuario no encontrado.';
  static const String notFoundCartFailureMessage = 'Carrito no encontrado.';
  static const String clientFailureMessage = 'Error en la petición.';
  static const String connectionFailureMessage =
      'Error de conexión a internet.';
  static const String unexpectedFailureMessage = 'Error inesperado:';

  // Etiquetas
  static const String productsLabel = 'productos.';
  static const String categoriesLabel = 'categorías.';
  static const String usersLabel = 'usuarios.';
  static const String cartsLabel = 'carritos.';
  static const String productLabel = 'Producto';
  static const String userLabel = 'Usuario';
  static const String cartLabel = 'Carrito';

  // Detalles del producto
  static const String productId = 'ID:';
  static const String productTitle = 'Título:';
  static const String productCategory = 'Categoría:';
  static const String productPrice = 'Precio:';
  static const String productDescription = 'Descripción:';
  static const String productImage = 'Imagen:';

  // Detalles del usuario
  static const String userId = 'ID:';
  static const String userUsername = 'Usuario:';
  static const String userEmail = 'Email:';
  static const String userName = 'Nombre:';
  static const String userPhone = 'Teléfono:';
  static const String userAddress = 'Dirección:';
  static const String userAddressStreet = '  Calle:';
  static const String userAddressCity = '  Ciudad:';
  static const String userAddressZipcode = '  Código Postal:';
  static const String userAddressCoords = '  Coordenadas:';

  // Detalles del carrito
  static const String cartId = 'ID:';
  static const String cartUserId = 'Usuario ID:';
  static const String cartDate = 'Fecha:';
  static const String cartProducts = 'Productos:';
  static const String cartProductId = '  - Producto ID:';
  static const String cartProductQuantity = '    Cantidad:';
  static const String cartNoProducts = '  (Sin productos)';
}
