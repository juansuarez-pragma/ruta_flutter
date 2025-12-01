import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_products_by_category_usecase.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

/// Controlador principal que coordina la interacción entre la UI y los casos de uso.
///
/// Esta clase actúa como el punto de entrada de la aplicación, orquestando
/// el flujo de la aplicación sin conocer los detalles de implementación
/// de la UI. Recibe una instancia de [UserInterface] que puede ser cualquier
/// implementación (consola, GUI, web, etc.).
class ApplicationController {
  final UserInterface _ui;
  final GetAllProductsUseCase _getAllProducts;
  final GetProductByIdUseCase _getProductById;
  final GetAllCategoriesUseCase _getAllCategories;
  final GetProductsByCategoryUseCase _getProductsByCategory;
  final void Function() _onExit;

  ApplicationController({
    required UserInterface ui,
    required GetAllProductsUseCase getAllProducts,
    required GetProductByIdUseCase getProductById,
    required GetAllCategoriesUseCase getAllCategories,
    required GetProductsByCategoryUseCase getProductsByCategory,
    required void Function() onExit,
  }) : _ui = ui,
       _getAllProducts = getAllProducts,
       _getProductById = getProductById,
       _getAllCategories = getAllCategories,
       _getProductsByCategory = getProductsByCategory,
       _onExit = onExit;

  /// Inicia el bucle principal de la aplicación.
  ///
  /// Muestra el menú y procesa las opciones del usuario hasta que
  /// seleccione salir.
  Future<void> run() async {
    _ui.showWelcome(AppStrings.welcomeMessage);

    MenuOption option;
    do {
      option = await _ui.showMainMenu();

      switch (option) {
        case MenuOption.getAllProducts:
          await _handleGetAllProducts();
        case MenuOption.getProductById:
          await _handleGetProductById();
        case MenuOption.getAllCategories:
          await _handleGetAllCategories();
        case MenuOption.getProductsByCategory:
          await _handleGetProductsByCategory();
        case MenuOption.exit:
          break;
        case MenuOption.invalid:
          _ui.showError(AppStrings.invalidOptionError);
      }
    } while (option != MenuOption.exit);

    _ui.showGoodbye();
    _onExit();
  }

  Future<void> _handleGetAllProducts() async {
    _ui.showOperationInfo(AppStrings.getAllProductsUseCaseTitle);

    final result = await _getAllProducts(const NoParams());

    result.fold(
      (failure) => _ui.showError(failure.message),
      (products) => _ui.showProducts(products),
    );
  }

  Future<void> _handleGetProductById() async {
    final id = await _ui.promptProductId();

    if (id == null) {
      _ui.showError(AppStrings.invalidIdError);
      return;
    }

    _ui.showOperationInfo('${AppStrings.getProductByIdUseCaseTitle} (ID: $id)');

    final result = await _getProductById(GetProductByIdParams(id: id));

    result.fold(
      (failure) => _ui.showError(failure.message),
      (product) => _ui.showProduct(product),
    );
  }

  Future<void> _handleGetAllCategories() async {
    _ui.showOperationInfo(AppStrings.getAllCategoriesUseCaseTitle);

    final result = await _getAllCategories(const NoParams());

    result.fold(
      (failure) => _ui.showError(failure.message),
      (categories) => _ui.showCategories(categories),
    );
  }

  Future<void> _handleGetProductsByCategory() async {
    // Primero obtenemos las categorías disponibles
    final categoriesResult = await _getAllCategories(const NoParams());

    final categories = categoriesResult.fold((failure) {
      _ui.showError(failure.message);
      return <String>[];
    }, (categories) => categories);

    if (categories.isEmpty) {
      return;
    }

    // Solicitamos al usuario que seleccione una categoría
    final selectedCategory = await _ui.promptCategory(categories);

    if (selectedCategory == null) {
      _ui.showError(AppStrings.invalidCategoryError);
      return;
    }

    _ui.showOperationInfo(
      '${AppStrings.getProductsByCategoryUseCaseTitle} ($selectedCategory)',
    );

    final result = await _getProductsByCategory(
      CategoryParams(category: selectedCategory),
    );

    result.fold(
      (failure) => _ui.showError(failure.message),
      (products) => _ui.showProducts(products),
    );
  }
}
