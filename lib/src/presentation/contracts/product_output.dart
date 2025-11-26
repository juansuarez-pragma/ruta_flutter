import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

/// Contrato para mostrar datos de productos.
abstract class ProductOutput {
  /// Muestra una lista de productos.
  void showProducts(List<ProductEntity> products);

  /// Muestra un producto individual.
  void showProduct(ProductEntity product);
}
