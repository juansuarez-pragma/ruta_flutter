import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/user_interface.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

/// Coordina la interacción entre la interfaz de usuario y los casos de uso.
///
/// Esta clase actúa como el punto de entrada de la aplicación, orquestando
/// el flujo de la aplicación sin conocer los detalles de implementación
/// de la UI. Recibe una instancia de [UserInterface] que puede ser cualquier
/// implementación (consola, GUI, web, etc.).
///
/// Sigue el principio de inversión de dependencias: depende de abstracciones
/// ([UserInterface]) no de implementaciones concretas.
class Application {
  final UserInterface _ui;
  final GetAllProductsUseCase _getAllProducts;
  final GetProductByIdUseCase _getProductById;
  final GetAllCategoriesUseCase _getAllCategories;
  final void Function() _onExit;

  Application({
    required UserInterface ui,
    required GetAllProductsUseCase getAllProducts,
    required GetProductByIdUseCase getProductById,
    required GetAllCategoriesUseCase getAllCategories,
    required void Function() onExit,
  }) : _ui = ui,
       _getAllProducts = getAllProducts,
       _getProductById = getProductById,
       _getAllCategories = getAllCategories,
       _onExit = onExit;

  /// Inicia el bucle principal de la aplicación.
  ///
  /// Muestra el menú y procesa las opciones del usuario hasta que
  /// seleccione salir.
  Future<void> run() async {
    _ui.showWelcome(AppStrings.welcomeMessage);

    var running = true;
    while (running) {
      final option = await _ui.showMainMenu();

      switch (option) {
        case MenuOption.getAllProducts:
          await _handleGetAllProducts();
        case MenuOption.getProductById:
          await _handleGetProductById();
        case MenuOption.getAllCategories:
          await _handleGetAllCategories();
        case MenuOption.exit:
          running = false;
        case MenuOption.invalid:
          _ui.showError(AppStrings.invalidOptionError);
      }
    }

    _ui.showGoodbye();
    _ui.dispose();
    _onExit();
  }

  Future<void> _handleGetAllProducts() async {
    _ui.showLoading(AppStrings.getAllProductsUseCaseTitle);

    final result = await _getAllProducts(const NoParams());

    result.fold(
      (failure) => _ui.showError(failure.message),
      (products) => _ui.showProducts(products),
    );

    _ui.hideLoading();
  }

  Future<void> _handleGetProductById() async {
    final id = await _ui.promptProductId();

    if (id == null) {
      _ui.showError(AppStrings.invalidIdError);
      return;
    }

    _ui.showLoading('${AppStrings.getProductByIdUseCaseTitle} (ID: $id)');

    final result = await _getProductById(GetProductByIdParams(id: id));

    result.fold(
      (failure) => _ui.showError(failure.message),
      (product) => _ui.showProduct(product),
    );

    _ui.hideLoading();
  }

  Future<void> _handleGetAllCategories() async {
    _ui.showLoading(AppStrings.getAllCategoriesUseCaseTitle);

    final result = await _getAllCategories(const NoParams());

    result.fold(
      (failure) => _ui.showError(failure.message),
      (categories) => _ui.showCategories(categories),
    );

    _ui.hideLoading();
  }
}
