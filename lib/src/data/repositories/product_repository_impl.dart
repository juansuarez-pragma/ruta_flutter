import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/datasources/api_datasource.dart';
import 'package:fase_2_consumo_api/src/data/repositories/base/base_repository.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

class ProductRepositoryImpl extends BaseRepository
    implements ProductRepository {
  final ApiDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts() async {
    return await handleRequest(() async {
      final productModels = await remoteDataSource.getAllProducts();
      final productEntities = productModels
          .map((model) => model.toEntity())
          .toList();
      return productEntities;
    });
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    return await handleRequest(() async {
      final productModel = await remoteDataSource.getProductById(id);
      return productModel.toEntity();
    }, notFoundMessage: AppStrings.notFoundProductFailureMessage);
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    // Las categorías son solo strings, no necesitan mapeo
    return await handleRequest(
      () => remoteDataSource.getAllCategories(),
      notFoundMessage: AppStrings.notFoundCategoriesFailureMessage,
    );
  }
}
