import 'package:fase_2_consumo_api/src/data/models/product_model.dart';

/// Interfaz abstracta para el origen de datos de la API.
abstract class ApiDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> getProductById(int id);
  Future<List<String>> getAllCategories();
}
