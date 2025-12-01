import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';

/// Interfaz del repositorio de productos.
///
/// Define el contrato para acceder a los datos de productos.
/// La implementación concreta está en la capa de datos.
abstract class ProductRepository {
  /// Obtiene todos los productos.
  Future<Either<Failure, List<ProductEntity>>> getAllProducts();

  /// Obtiene un producto por su ID.
  Future<Either<Failure, ProductEntity>> getProductById(int id);

  /// Obtiene todas las categorías disponibles.
  Future<Either<Failure, List<String>>> getAllCategories();

  /// Obtiene productos filtrados por categoría.
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  );
}
