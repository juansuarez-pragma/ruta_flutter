import 'dart:io';

import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/presentation/contracts/contracts.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

/// Adaptador de interfaz de usuario para consola/terminal.
///
/// Implementa el contrato [UserInterface] usando stdin/stdout para
/// interactuar con el usuario a través de la línea de comandos.
class ConsoleUserInterface implements UserInterface {
  static const int _labelPadding =
      12; // Alinea las etiquetas a la izquierda con un ancho fijo de 12 caracteres:
  static const int _descriptionMaxLength =
      70; //  Trunca descripciones largas a 70 caracteres para que no desborden la consola:

  @override
  void showWelcome(String message) {
    print(message);
  }

  @override
  Future<MenuOption> showMainMenu() async {
    print('\n${AppStrings.menuTitle}');
    print('1. ${AppStrings.menuOptionGetAllProducts}');
    print('2. ${AppStrings.menuOptionGetProductById}');
    print('3. ${AppStrings.menuOptionGetAllCategories}');
    print('4. ${AppStrings.menuOptionExit}');
    stdout.write('${AppStrings.menuPrompt} ');

    final choice = stdin.readLineSync()?.trim();

    return switch (choice) {
      '1' => MenuOption.getAllProducts,
      '2' => MenuOption.getProductById,
      '3' => MenuOption.getAllCategories,
      '4' => MenuOption.exit,
      _ => MenuOption.invalid,
    };
  }

  @override
  Future<int?> promptProductId() async {
    stdout.write('${AppStrings.promptProductId} ');
    final input = stdin.readLineSync()?.trim();
    return int.tryParse(input ?? '');
  }

  @override
  void showOperationInfo(String operationName) {
    print('\n${AppStrings.separator}');
    print('${AppStrings.executingUseCase} $operationName');
    print(AppStrings.separator);
  }

  @override
  void showError(String message) {
    print('${AppStrings.errorPrefix} $message\n');
  }

  @override
  void showProducts(List<ProductEntity> products) {
    print(
      '${AppStrings.successFound} ${products.length} ${AppStrings.productsLabel}\n',
    );
    for (final product in products) {
      _printProduct(
        product,
        '--- ${AppStrings.productLabel} ${product.id} ---',
      );
    }
  }

  @override
  void showProduct(ProductEntity product) {
    _printProduct(product, '--- ${AppStrings.productLabel} ${product.id} ---');
  }

  @override
  void showCategories(List<String> categories) {
    print(
      '${AppStrings.successFound} ${categories.length} ${AppStrings.categoriesLabel}\n',
    );
    for (final category in categories) {
      print('- $category');
    }
    print('');
  }

  @override
  void showGoodbye() {
    print('\n${AppStrings.executionEnd}');
  }

  void _printProduct(ProductEntity product, String header) {
    print(header);
    print('${AppStrings.productId.padRight(_labelPadding)}${product.id}');
    print('${AppStrings.productTitle.padRight(_labelPadding)}${product.title}');
    print(
      '${AppStrings.productCategory.padRight(_labelPadding)}${product.category}',
    );
    print(
      '${AppStrings.productPrice.padRight(_labelPadding)}\$${product.price}',
    );

    final descriptionLength = product.description.length;
    final truncatedDescription = product.description.substring(
      0,
      descriptionLength > _descriptionMaxLength
          ? _descriptionMaxLength
          : descriptionLength,
    );
    print(
      '${AppStrings.productDescription.padRight(_labelPadding)}$truncatedDescription...',
    );
    print(
      '${AppStrings.productImage.padRight(_labelPadding)}${product.image}\n',
    );
  }
}
