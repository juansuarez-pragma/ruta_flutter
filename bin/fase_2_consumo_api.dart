import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/core/injection_container.dart' as di;
import 'package:fase_2_consumo_api/src/core/usecase/usecase.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_categories_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_all_products_usecase.dart';
import 'package:fase_2_consumo_api/src/domain/usecases/get_product_by_id_usecase.dart';
import 'package:fase_2_consumo_api/util/strings.dart';

void main(List<String> arguments) async {
  // 1. Inicializar dependencias
  di.init();

  print('--- Bienvenido al Cliente Interactivo de Fake Store API ---\n');

  // 2. Bucle principal de la aplicación
  while (true) {
    _showMenu();
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        await _handleGetAllProducts();
        break;
      case '2':
        await _handleGetProductById();
        break;
      case '3':
        await _handleGetAllCategories();
        break;
      case '4':
        print('\n${AppStrings.executionEnd}');
        di.sl<http.Client>().close();
        return; // Salir de la aplicación
      default:
        print('\n>> ERROR: Opción no válida. Por favor, intenta de nuevo.');
    }
  }
}

void _showMenu() {
  print('\nPor favor, elige una opción:');
  print('1. Obtener todos los productos');
  print('2. Obtener un producto por ID');
  print('3. Obtener todas las categorías');
  print('4. Salir');
  stdout.write('Opción: ');
}

Future<void> _handleGetAllProducts() async {
  final getAllProducts = di.sl<GetAllProductsUseCase>();
  await _executeUseCase<List<ProductEntity>>(
    AppStrings.getAllProductsUseCaseTitle,
    () => getAllProducts(const NoParams()),
    (products) {
      print('${AppStrings.successFound} ${products.length} productos.\n');
      for (var product in products) {
        _printProduct(product, '--- Producto ${product.id} ---');
      }
    },
  );
}

Future<void> _handleGetProductById() async {
  stdout.write('Por favor, ingresa el ID del producto: ');
  final idString = stdin.readLineSync();
  final id = int.tryParse(idString ?? '');

  if (id == null) {
    print('\n>> ERROR: ID no válido.');
    return;
  }

  final getProductById = di.sl<GetProductByIdUseCase>();
  await _executeUseCase<ProductEntity>(
    'GetProductByIdUseCase (ID: $id)',
    () => getProductById(GetProductByIdParams(id: id)),
    (product) => _printProduct(product, '--- Producto $id ---'),
  );
}

Future<void> _handleGetAllCategories() async {
  final getAllCategories = di.sl<GetAllCategoriesUseCase>();
  await _executeUseCase<List<String>>(
    AppStrings.getAllCategoriesUseCaseTitle,
    () => getAllCategories(const NoParams()),
    (categories) {
      print('${AppStrings.successFound} ${categories.length} categorías.\n');
      for (var category in categories) {
        print('- $category');
      }
      print('');
    },
  );
}

// Función auxiliar para ejecutar y manejar el resultado de un caso de uso
Future<void> _executeUseCase<T>(
  String useCaseName,
  Future<Either<Failure, T>> Function() execute,
  void Function(T data) onSuccess,
) async {
  print('\n--------------------------------------------------');
  print('${AppStrings.executingUseCase} $useCaseName');
  print('--------------------------------------------------');

  final result = await execute();

  result.fold(
    (failure) => print('${AppStrings.errorPrefix} ${failure.message}\n'),
    (data) => onSuccess(data),
  );
}

// Función auxiliar para imprimir detalles de un producto
void _printProduct(ProductEntity product, String header) {
  print('$header');
  print('${AppStrings.productId.padRight(12)}${product.id}');
  print('${AppStrings.productTitle.padRight(12)}${product.title}');
  print('${AppStrings.productCategory.padRight(12)}${product.category}');
  print('${AppStrings.productPrice.padRight(12)}\$${product.price}');
  print('${AppStrings.productDescription.padRight(12)}${product.description.substring(0, product.description.length > 70 ? 70 : product.description.length)}...');
  print('${AppStrings.productImage.padRight(12)}${product.image}\n');
}