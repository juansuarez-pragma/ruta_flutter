import 'package:equatable/equatable.dart';

/// Entidad que representa un producto del dominio.
///
/// Es inmutable y usa [Equatable] para comparación por valor.
class ProductEntity extends Equatable {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  @override
  List<Object?> get props => [id, title, price, description, category, image];
}
