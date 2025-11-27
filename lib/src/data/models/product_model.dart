import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

/// Modelo de datos para un producto.
///
/// Maneja la serialización/deserialización de JSON y la conversión
/// a la entidad de dominio [ProductEntity].
class ProductModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  const ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  /// Crea un [ProductModel] a partir de un mapa JSON.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
    );
  }

  /// Convierte este modelo a una entidad de dominio.
  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      price: price,
      description: description,
      category: category,
      image: image,
    );
  }
}
