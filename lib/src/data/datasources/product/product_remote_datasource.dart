import 'package:fase_2_consumo_api/src/data/models/product_model.dart';

/// Interface para el origen de datos remoto de productos.
abstract class ProductRemoteDataSource {
  /// Obtiene todos los productos desde la API.
  Future<List<ProductModel>> getAll();

  /// Obtiene un producto por su ID.
  Future<ProductModel> getById(int id);
}
