import 'package:dartz/dartz.dart';
import 'package:fase_2_consumo_api/src/core/errors/failures.dart';
import 'package:fase_2_consumo_api/src/data/datasources/category/category_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/datasources/product/product_remote_datasource.dart';
import 'package:fase_2_consumo_api/src/data/repositories/base/base_repository.dart';
import 'package:fase_2_consumo_api/src/domain/entities/product_entity.dart';
import 'package:fase_2_consumo_api/src/domain/repositories/product_repository.dart';
import 'package:fase_2_consumo_api/src/util/strings.dart';

class ProductRepositoryImpl extends BaseRepository
    implements ProductRepository {
  final ProductRemoteDataSource _productDataSource;
  final CategoryRemoteDataSource _categoryDataSource;

  ProductRepositoryImpl({
    required ProductRemoteDataSource productDataSource,
    required CategoryRemoteDataSource categoryDataSource,
  }) : _productDataSource = productDataSource,
       _categoryDataSource = categoryDataSource;

  @override
  Future<Either<Failure, List<ProductEntity>>> getAllProducts() async {
    return await handleRequest(() async {
      final productModels = await _productDataSource.getAll();
      return productModels.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) async {
    return await handleRequest(() async {
      final productModel = await _productDataSource.getById(id);
      return productModel.toEntity();
    }, notFoundMessage: AppStrings.notFoundProductFailureMessage);
  }

  @override
  Future<Either<Failure, List<String>>> getAllCategories() async {
    return await handleRequest(
      () => _categoryDataSource.getAll(),
      notFoundMessage: AppStrings.notFoundCategoriesFailureMessage,
    );
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    String category,
  ) async {
    return await handleRequest(() async {
      final productModels = await _productDataSource.getByCategory(category);
      return productModels.map((model) => model.toEntity()).toList();
    }, notFoundMessage: AppStrings.notFoundCategoriesFailureMessage);
  }
}
