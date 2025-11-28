/// Helpers y utilidades compartidas para testing.
///
/// Proporciona funciones de fábrica para crear entidades y modelos
/// de prueba de manera consistente.
library;

import 'package:fase_2_consumo_api/src/data/models/product_model.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

/// Crea una [ProductEntity] de prueba con valores por defecto.
///
/// Permite sobrescribir cualquier campo para casos de prueba específicos.
ProductEntity createTestProductEntity({
  int id = 1,
  String title = 'Producto de prueba',
  double price = 99.99,
  String description = 'Descripción del producto de prueba',
  String category = 'electronics',
  String image = 'https://example.com/image.jpg',
}) {
  return ProductEntity(
    id: id,
    title: title,
    price: price,
    description: description,
    category: category,
    image: image,
  );
}

/// Crea un [ProductModel] de prueba con valores por defecto.
///
/// Permite sobrescribir cualquier campo para casos de prueba específicos.
ProductModel createTestProductModel({
  int id = 1,
  String title = 'Producto de prueba',
  double price = 99.99,
  String description = 'Descripción del producto de prueba',
  String category = 'electronics',
  String image = 'https://example.com/image.jpg',
}) {
  return ProductModel(
    id: id,
    title: title,
    price: price,
    description: description,
    category: category,
    image: image,
  );
}

/// Crea una lista de [ProductEntity] de prueba.
List<ProductEntity> createTestProductEntityList({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestProductEntity(
      id: index + 1,
      title: 'Producto ${index + 1}',
      price: (index + 1) * 10.0,
    ),
  );
}

/// Crea una lista de [ProductModel] de prueba.
List<ProductModel> createTestProductModelList({int count = 2}) {
  return List.generate(
    count,
    (index) => createTestProductModel(
      id: index + 1,
      title: 'Producto ${index + 1}',
      price: (index + 1) * 10.0,
    ),
  );
}

/// Lista de categorías de prueba.
List<String> createTestCategories() {
  return ['electronics', 'jewelery', "men's clothing", "women's clothing"];
}
