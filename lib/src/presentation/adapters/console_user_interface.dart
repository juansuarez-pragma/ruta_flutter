import 'dart:io';

import 'package:fase_2_consumo_api/src/domain/entities/cart_entity.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/entities/user_entity.dart';
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
    print('4. ${AppStrings.menuOptionGetProductsByCategory}');
    print('5. ${AppStrings.menuOptionGetAllUsers}');
    print('6. ${AppStrings.menuOptionGetUserById}');
    print('7. ${AppStrings.menuOptionGetAllCarts}');
    print('8. ${AppStrings.menuOptionGetCartById}');
    print('9. ${AppStrings.menuOptionGetCartsByUser}');
    print('10. ${AppStrings.menuOptionExit}');
    stdout.write('${AppStrings.menuPrompt} ');

    final choice = stdin.readLineSync()?.trim();

    return switch (choice) {
      '1' => MenuOption.getAllProducts,
      '2' => MenuOption.getProductById,
      '3' => MenuOption.getAllCategories,
      '4' => MenuOption.getProductsByCategory,
      '5' => MenuOption.getAllUsers,
      '6' => MenuOption.getUserById,
      '7' => MenuOption.getAllCarts,
      '8' => MenuOption.getCartById,
      '9' => MenuOption.getCartsByUser,
      '10' => MenuOption.exit,
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
  Future<int?> promptUserId() async {
    stdout.write('${AppStrings.promptUserId} ');
    final input = stdin.readLineSync()?.trim();
    return int.tryParse(input ?? '');
  }

  @override
  Future<String?> promptCategory(List<String> categories) async {
    print('\n${AppStrings.promptCategory}');
    for (var i = 0; i < categories.length; i++) {
      print('${i + 1}. ${categories[i]}');
    }
    stdout.write('${AppStrings.menuPrompt} ');

    final input = stdin.readLineSync()?.trim();
    final index = int.tryParse(input ?? '');

    if (index == null || index < 1 || index > categories.length) {
      return null;
    }

    return categories[index - 1];
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

  @override
  void showUsers(List<UserEntity> users) {
    print(
      '${AppStrings.successFound} ${users.length} ${AppStrings.usersLabel}\n',
    );
    for (final user in users) {
      _printUserSummary(user);
    }
  }

  @override
  void showUser(UserEntity user) {
    _printUserDetail(user);
  }

  void _printUserSummary(UserEntity user) {
    print('--- ${AppStrings.userLabel} ${user.id} ---');
    print('${AppStrings.userId.padRight(_labelPadding)}${user.id}');
    print('${AppStrings.userUsername.padRight(_labelPadding)}${user.username}');
    print('${AppStrings.userEmail.padRight(_labelPadding)}${user.email}');
    print(
      '${AppStrings.userName.padRight(_labelPadding)}${user.name.firstname} ${user.name.lastname}',
    );
    print('${AppStrings.userPhone.padRight(_labelPadding)}${user.phone}\n');
  }

  void _printUserDetail(UserEntity user) {
    print('--- ${AppStrings.userLabel} ${user.id} ---');
    print('${AppStrings.userId.padRight(_labelPadding)}${user.id}');
    print('${AppStrings.userUsername.padRight(_labelPadding)}${user.username}');
    print('${AppStrings.userEmail.padRight(_labelPadding)}${user.email}');
    print(
      '${AppStrings.userName.padRight(_labelPadding)}${user.name.firstname} ${user.name.lastname}',
    );
    print('${AppStrings.userPhone.padRight(_labelPadding)}${user.phone}');
    print(AppStrings.userAddress);
    print(
      '${AppStrings.userAddressStreet.padRight(_labelPadding)}${user.address.street} ${user.address.number}',
    );
    print(
      '${AppStrings.userAddressCity.padRight(_labelPadding)}${user.address.city}',
    );
    print(
      '${AppStrings.userAddressZipcode.padRight(_labelPadding)}${user.address.zipcode}',
    );
    print(
      '${AppStrings.userAddressCoords.padRight(_labelPadding)}${user.address.geolocation.lat}, ${user.address.geolocation.long}\n',
    );
  }

  // ============================================
  // Métodos de Cart
  // ============================================

  @override
  Future<int?> promptCartId() async {
    stdout.write('${AppStrings.promptCartId} ');
    final input = stdin.readLineSync()?.trim();
    return int.tryParse(input ?? '');
  }

  @override
  Future<int?> promptUserIdForCarts() async {
    stdout.write('${AppStrings.promptUserIdForCarts} ');
    final input = stdin.readLineSync()?.trim();
    return int.tryParse(input ?? '');
  }

  @override
  void showCarts(List<CartEntity> carts) {
    print(
      '${AppStrings.successFound} ${carts.length} ${AppStrings.cartsLabel}\n',
    );
    for (final cart in carts) {
      _printCartSummary(cart);
    }
  }

  @override
  void showCart(CartEntity cart) {
    _printCartDetail(cart);
  }

  void _printCartSummary(CartEntity cart) {
    print('--- ${AppStrings.cartLabel} ${cart.id} ---');
    print('${AppStrings.cartId.padRight(_labelPadding)}${cart.id}');
    print('${AppStrings.cartUserId.padRight(_labelPadding)}${cart.userId}');
    print(
      '${AppStrings.cartDate.padRight(_labelPadding)}${_formatDate(cart.date)}',
    );
    print(
      '${AppStrings.cartProducts.padRight(_labelPadding)}${cart.products.length} items\n',
    );
  }

  void _printCartDetail(CartEntity cart) {
    print('--- ${AppStrings.cartLabel} ${cart.id} ---');
    print('${AppStrings.cartId.padRight(_labelPadding)}${cart.id}');
    print('${AppStrings.cartUserId.padRight(_labelPadding)}${cart.userId}');
    print(
      '${AppStrings.cartDate.padRight(_labelPadding)}${_formatDate(cart.date)}',
    );
    print(AppStrings.cartProducts);
    if (cart.products.isEmpty) {
      print(AppStrings.cartNoProducts);
    } else {
      for (final product in cart.products) {
        print('${AppStrings.cartProductId} ${product.productId}');
        print('${AppStrings.cartProductQuantity} ${product.quantity}');
      }
    }
    print('');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
